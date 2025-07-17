#!/bin/bash
set -euxo pipefail

# Log everything to a file for debugging
exec > >(tee -a /var/log/bootstrap.log)
exec 2>&1

echo "Bootstrap script started at $(date)"

# Install AWS CLI and other required packages
echo "Updating system packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y || { echo "System update failed"; exit 1; }

echo "Installing required packages..."
apt-get install -y apache2 php php-mysql mysql-client awscli jq || { echo "Package installation failed"; exit 1; }

# Enable and start Apache
echo "Configuring Apache..."
systemctl enable apache2 || { echo "Failed to enable apache2"; exit 1; }
systemctl start apache2 || { echo "Failed to start apache2"; exit 1; }

# Get AWS region from instance metadata
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)

# Fetch database credentials from SSM Parameter Store
echo "Fetching database credentials from SSM..."
DB_HOST=$(aws ssm get-parameter --name "db_host" --region $REGION --with-decryption --query "Parameter.Value" --output text)
DB_USER=$(aws ssm get-parameter --name "db_username" --region $REGION --with-decryption --query "Parameter.Value" --output text)
DB_PASS=$(aws ssm get-parameter --name "db_password" --region $REGION --with-decryption --query "Parameter.Value" --output text)
DB_NAME=$(aws ssm get-parameter --name "db_name" --region $REGION --with-decryption --query "Parameter.Value" --output text)

# Verify we got all parameters
if [ -z "$DB_HOST" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASS" ] || [ -z "$DB_NAME" ]; then
    echo "ERROR: Failed to retrieve one or more database parameters from SSM"
    exit 1
fi

# Create inc directory and DB config
echo "Setting up database configuration..."
mkdir -p /var/www/inc

cat <<EOF > /var/www/inc/dbinfo.inc
<?php
define('DB_SERVER', '$DB_HOST');
define('DB_USERNAME', '$DB_USER');
define('DB_PASSWORD', '$DB_PASS');
define('DB_DATABASE', '$DB_NAME');
?>
EOF

# Secure permissions - Ubuntu uses www-data user
chown -R www-data:www-data /var/www
chmod 640 /var/www/inc/dbinfo.inc

# Wait for database to be ready with retry logic
echo "Waiting for database to be ready..."
DB_READY=false
for i in {1..60}; do
    echo "Database connection attempt $i/60..."
    # Ubuntu uses mysql command with proper hostname and port separation
    if mysql -h "${DB_HOST}" -P 3306 -u "${DB_USER}" -p"${DB_PASS}" -e "SELECT 1;" 2>/dev/null; then
        echo "Database connection successful!"
        DB_READY=true
        break
    fi
    echo "Database not ready yet, waiting 10 seconds..."
    sleep 10
done

if [ "$DB_READY" = false ]; then
    echo "ERROR: Database connection failed after 60 attempts (10 minutes)"
    echo "Debug info:"
    echo "  DB_HOST: ${DB_HOST}"
    echo "  DB_USER: ${DB_USER}"
    echo "  DB_NAME: ${DB_NAME}"
    # Try to test connectivity to the host
    echo "Testing network connectivity to database host..."
    if ping -c 3 "${DB_HOST}" 2>/dev/null; then
        echo "  Host is reachable via ping"
    else
        echo "  Host is NOT reachable via ping"
    fi
    
    # Try to test port connectivity
    if timeout 10 bash -c "</dev/tcp/${DB_HOST}/3306" 2>/dev/null; then
        echo "  Port 3306 is open"
    else
        echo "  Port 3306 is NOT accessible"
    fi
    
    echo "Attempting to continue without database setup..."
fi

# Initialize database and table using MySQL client (only if connection works)
if [ "$DB_READY" = true ]; then
    echo "Setting up database and tables..."
    # Ubuntu uses mysql command with proper hostname and port separation
    mysql -h "${DB_HOST}" -P 3306 -u "${DB_USER}" -p"${DB_PASS}" <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
USE ${DB_NAME};
CREATE TABLE IF NOT EXISTS EMPLOYEES (
  ID int(11) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  NAME VARCHAR(45),
  AGE INTEGER(3),
  CITY VARCHAR(45)
);

MYSQL_SCRIPT
    echo "Database setup completed successfully!"
else
    echo "Skipping database setup due to connection issues"
fi

# Deploy the application file corp.php
echo "Deploying web application..."
cat <<'EOF' > /var/www/html/corp.php
<?php include "../inc/dbinfo.inc"; ?>
<html>
<body>
<h1> Welcome to my project website database !</h1>
<?php
  $connection = mysqli_connect(DB_SERVER, DB_USERNAME, DB_PASSWORD);
  if (mysqli_connect_errno()) echo "Failed to connect to MySQL: " . mysqli_connect_error();

  $database = mysqli_select_db($connection, DB_DATABASE);
  VerifyEmployeesTable($connection, DB_DATABASE);

  $employee_name = htmlentities($_POST['NAME']);
  $employee_age = htmlentities($_POST['AGE']);
  $employee_city = htmlentities($_POST['CITY']);

  if (strlen($employee_name) || strlen($employee_city)) {
    AddEmployee($connection, $employee_name, $employee_age, $employee_city);
  }
?>

<form action="<?PHP echo $_SERVER['SCRIPT_NAME'] ?>" method="POST">
  <table border="0">
    <tr>
      <td>NAME</td>
      <td>AGE</td>
      <td>CITY</td>
    </tr>
    <tr>
      <td><input type="text" name="NAME" maxlength="45" size="30" /></td>
      <td><input type="text" name="AGE" maxlength="45" size="30" /></td>
      <td><input type="text" name="CITY" maxlength="45" size="30" /></td>
      <td><input type="submit" value="Add Data" /></td>
    </tr>
  </table>
</form>

<table border="1" cellpadding="2" cellspacing="2">
  <tr>
    <td>ID</td>
    <td>NAME</td>
    <td>AGE</td>
    <td>CITY</td>
  </tr>

<?php
$result = mysqli_query($connection, "SELECT * FROM EMPLOYEES");
while($query_data = mysqli_fetch_row($result)) {
  echo "<tr>";
  echo "<td>",$query_data[0], "</td>",
       "<td>",$query_data[1], "</td>",
       "<td>",$query_data[2], "</td>",
       "<td>",$query_data[3], "</td>";
  echo "</tr>";
}
?>
</table>

<?php
  mysqli_free_result($result);
  mysqli_close($connection);

function AddEmployee($connection, $name, $age, $city) {
   $n = mysqli_real_escape_string($connection, $name);
   $a = mysqli_real_escape_string($connection, $age);
   $c = mysqli_real_escape_string($connection, $city);
   $query = "INSERT INTO EMPLOYEES (NAME, AGE, CITY) VALUES ('$n', '$a', '$c');";
   if(!mysqli_query($connection, $query)) echo("<p>Error adding employee data.</p>");
}

function VerifyEmployeesTable($connection, $dbName) {
  if(!TableExists("EMPLOYEES", $connection, $dbName)) {
     $query = "CREATE TABLE EMPLOYEES (
         ID int(11) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
         NAME VARCHAR(45),
         AGE INTEGER(3),
         CITY VARCHAR(45)
       )";
     if(!mysqli_query($connection, $query)) echo("<p>Error creating table.</p>");
  }
}

function TableExists($tableName, $connection, $dbName) {
  $t = mysqli_real_escape_string($connection, $tableName);
  $d = mysqli_real_escape_string($connection, $dbName);
  $checktable = mysqli_query($connection,
      "SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_NAME = '$t' AND TABLE_SCHEMA = '$d'");
  return mysqli_num_rows($checktable) > 0;
}
?>
</body>
</html>
EOF

# Set permissions - Ubuntu uses www-data user
chown www-data:www-data /var/www/html/corp.php
chmod 644 /var/www/html/corp.php

# Create a simple index.html for testing
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Web_database Server</title>
</head>
<body>
    <h1>Web_database Server is Running!</h1>
    <p>Bootstrap completed at: $(date)</p>
    <p><a href="corp.php">Go to Employee Database</a></p>
</body>
</html>
EOF

# Final status check
echo "=== Final Status Check ==="
echo "Apache status:"
systemctl status apache2 --no-pager -l

echo "Web files created:"
ls -la /var/www/html/
ls -la /var/www/inc/

echo "=== Bootstrap script completed at $(date) ==="
echo "Check logs with: sudo cat /var/log/bootstrap.log"
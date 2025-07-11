connect  to mysql
```
mysql -h <rds-endpoint> -u <username> -p
```

database to use
```
USE testdb;
```

tunneling
```
ssh -i "key_pair" -N -L 3306:<rds end_point>:3306 ubuntu@<public_ip>
```
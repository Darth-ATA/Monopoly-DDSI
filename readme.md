Es una versión simple del tradicional juego del Monopoly.
Está conectado con una una base de datos en MariaDB.

Forma parte de una práctica de evaluación de una asignatura
del grado al que pertenezco

Para hacer todo he usado los siguientes documentos:
Un tutorial de cómo conectar Ruby y MySQL
http://zetcode.com/db/mysqlrubytutorial/

Otro tutorial parecido
http://www.codebeach.com/2009/10/ruby-and-mysql-tutorial.html?m=1

Para usar Ruby, hemos de ejecutar irb nombre_archivo.rb

Antes de poder ejecutar la práctica se tiene que tener instalado en el
sistema MariaDB (Implementación de MySQL) y RUBY(Lenguaje de Programación)

Además de tener una tabla y un usuario añadidos a MariaDB

Aquí se detallan los pasos a seguir para que todo quede listo para la ejecución, yo sé los pasos exactos para arch, pero cuando vea pacman o pacaur sustituyalo por el comando de instalación de su gestor de paquetes

1-	pacman -S mariadb
2-  systemctl start mysqld.service
3-  systemctl enable mysqld.service
4-	mysql_secure_installation
5-	mysql_upgrade -u root -p
6- 	mysql -u root -p
7-	CREATE USER monopoly@localhost IDENTIFIED BY 'some_pass';
8- CREATE DATABASE Monopoly
9- 	GRANT ALL PRIVILEGES ON Monopoly.* TO monopoly@localhost WITH GRANT OPTION
10-	quit

11- sudo pacman -S ruby
12-	añadir en el bashrc PATH="$(ruby -e 'print Gem.user_dir')/bin:$PATH"
13-	gem install mysql
14-	gem update
15- gem install ruby
16- mysql -u root -p




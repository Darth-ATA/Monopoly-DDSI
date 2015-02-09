#!/usr/bin/irb
require 'mysql'

class Administrador
    def initialize(nombre = "admin")
        @nombre = nombre
        #Son dos variables que controlan el menú
        @gestionando = "OK"
        @subsistema = "OK"
        
        #Conecta con la base de datos y nos da la versión que se está usando
        @con = Mysql.new 'localhost', 'monopoly', 'monopoly', 'Monopoly'
        
        puts @con.get_server_info
        @rs = @con.query 'SELECT VERSION()'
        puts @rs.fetch_row 

    end
    #Inserción de un tablero en la base de datos
    def insertarTablero
        #Crea la tabla tablero si no la tenemos ya en el sistema
        @con.query("CREATE TABLE IF NOT EXISTS tablero(idTablero varchar(20) primary key, numeroCasillas int);")
        puts 'Inserte el idTablero que desea agregar'
        id_tablero = gets.chomp
        @con.query("INSERT INTO tablero(idTablero) VALUES('#{id_tablero}');")
    end
    def borrarTablero
        puts 'Inserte el idTablero que desea borrar'
        id_tablero = gets.chomp
        @con.query("DELETE FROM tablero where ('#{id_tablero}' = idTablero)")
    end
    def asociarCasilla
        puts 'Inserte el idTablero que al que desea asociar casilla'
        id_tablero = gets.chomp
        puts 'Inserte el idCasilla que desea asociar'
        id_casilla = gets.chomp
        @con.query("INSERT INTO asociadas(idTablero,idCasilla) VALUES('#{id_tablero},#{id_casilla}")
    end
    def verTablero
        puts 'Inserte el idTablero que desea ver'
        id_tablero = gets.chomp
        @con.query("Select * from tablero where idTablero = '#{id_tablero}'")
    end
    def gestion
        while(@subsistema != "quit")
            puts "Bienvenido Administrador"
            puts "¿Qué desea gestionar? \n\t1- Tablero \n\t2- Casillas \n\t3- Tarjetas"
            print "Opcion: "
            gestionar = Integer(gets.chomp)
            if(gestionar == 1)
                while @gestionando != 9 do
                    puts "Gestión de Tableros"
                    puts "\t1- Insertar \n\t2- Borrar \n\t3- Asociar una casilla a un tablero \n\t4- Ver \n\t9- Salir"
                    print "Opcion: "
                    @gestionando = Integer(gets.chomp)
                    if(@gestionando == 1)
                        self.insertarTablero
                    elsif(@gestionando == 2)
                        self.borrarTablero
                    elsif(@gestionando == 3)
                        self.asociarCasilla
                    elsif(@gestionando == 4)
                        self.verTablero
                    end

                end
                @gestionando = "OK"
            elsif(gestionar == 2)
                while @gestionando != "quit" do
                    puts "Gestión de Casillas"
                    puts "\t1- Insertar \n\t2- Borrar \n\t3- Modificar"
                    print "Opcion: "
                    @gestionando = Integer(gets.chomp)
                end
                @gestionando = "OK"
            else
                while @gestionando != "quit" do
                    puts "Gestión de Tarjetas"
                    puts "\t1- Insertar \n\t2- Borrar \n\t3- Modificar"
                    print "Opcion: "
                    @gestionando = Integer(gets.chomp)
                end
                @gestionando = "OK"
            end
        end
    end
end

begin
    con = Mysql.new 'localhost', 'monopoly', 'monopoly', 'Monopoly'

    puts "En caso de ser un Administrador escriba 1."
    individuo = Integer(gets.chomp)
    if(individuo == 1)
        admin = Administrador.new("admin")
        admin.gestion        
    else
        print "Usuario: "
        usuario = gets.chomp
        print "Contraseña: "
        contraseña = gets.chomp
        puts "................."
        puts "Bienvenido a Monopoly #{usuario}"
    end

    
rescue Mysql::Error => e
    puts e.errno
    puts e.error
    
ensure
    con.close if con
end

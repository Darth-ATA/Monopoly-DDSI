#!/usr/bin/irb
require 'mysql'

class Administrador
    def initialize(nombre = "admin")
        @nombre = nombre
        #Son dos variables que controlan el menú
        @gestionando = 0
        @subsistema = 0
        
        #Conecta con la base de datos y nos da la versión que se está usando
        @con = Mysql.new 'localhost', 'monopoly', 'monopoly', 'Monopoly'
        
        puts @con.get_server_info
        @rs = @con.query 'SELECT VERSION()'
        puts @rs.fetch_row 

    end
    #Inserción de un tablero en la base de datos
    def insertarTablero
        #Crea la tabla tablero si no la tenemos ya en el sistema
        @con.query("CREATE TABLE IF NOT EXISTS tablero(idTablero varchar(20) PRIMARY KEY, numeroCasillas int);")
        puts 'Inserte el idTablero que desea agregar'
        id_tablero = gets.chomp
        @con.query("INSERT INTO tablero(idTablero) VALUES('#{id_tablero}');")
    end
    #Borrado de un tablero de la base de datos
    def borrarTablero
        puts 'Inserte el idTablero que desea borrar'
        id_tablero = gets.chomp
        @con.query("DELETE FROM tablero WHERE ('#{id_tablero}' = idTablero)")
    end
    #Asocia una casilla a un tablero
    def asociarCasilla
        @con.query("CREATE TABLE IF NOT EXISTS asociada(idTablero varchar(20) REFERENCES tablero(idTablero) \
                    ,idCasilla varchar(20) REFERENCES casilla(idCasilla) \
                    ,PRIMARY KEY(idTablero,idCasilla));")
        puts 'Inserte el idTablero que al que desea asociar casilla'
        id_tablero = gets.chomp
        puts 'Inserte el idCasilla que desea asociar'
        id_casilla = gets.chomp
        @con.query("INSERT INTO asociada(idTablero,idCasilla) VALUES('#{id_tablero}','#{id_casilla}')")
    end
    #Desasocia una casilla de un tablero
    def desAsociarCasilla
        puts 'Inserte el idTablero del que desea desasociar la casilla'
        id_tablero = gets.chomp
        puts 'Inserte la idCasilla de la casilla que desea desasociar'
        id_casilla = gets.chomp
        @con.query("DELETE FROM asociada WHERE ('#{id_tablero}' = idTablero && '#{id_casilla}' = idCasilla)")
    end
    #Ve el número de casillas y las casillas del tablero
    def verTablero
        puts 'Inserte el idTablero que desea ver'
        id_tablero = gets.chomp
        @con.query("SELECT * FROM tablero WHERE idTablero = '#{id_tablero}'")
        puts 'Sus casillas asociadas son:'
        @con.query("SELECT idCasilla FROM asociada WHERE idTablero = '#{id_tablero}'")
    end
    #Método que se ocupa del manejo de todas las funcionalidades del administrador
    def gestion
        while @subsistema != 9 do
            puts "Bienvenido Administrador"
            puts "¿Qué desea gestionar? \n\t1- Tablero \n\t2- Casillas \n\t3- Tarjetas \n\t9- Salir"
            print "Opcion: "
            @subsistema = Integer(gets.chomp)
            if @subsistema == 1
                while @gestionando != 9 do
                    puts "Gestión de Tableros"
                    puts "\t1- Insertar \n\t2- Borrar \n\t3- Asociar una casilla a un tablero \n\t4- Ver \n\t5- Desasociar Casilla \n\t9- Salir"
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
                    elsif(@gestionando == 5)
                        self.desAsociarCasilla
                    end

                end
                @gestionando = 0
            elsif @subsistema == 2
                while @gestionando != "quit" do
                    puts "Gestión de Casillas"
                    puts "\t1- Insertar \n\t2- Borrar \n\t3- Modificar"
                    print "Opcion: "
                    @gestionando = Integer(gets.chomp)
                end
                @gestionando = 0
            elsif @subsistema == 3
                while @gestionando != "quit" do
                    puts "Gestión de Tarjetas"
                    puts "\t1- Insertar \n\t2- Borrar \n\t3- Modificar"
                    print "Opcion: "
                    @gestionando = Integer(gets.chomp)
                end
                @gestionando = 0
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

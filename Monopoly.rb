#!/usr/bin/irb

require 'mysql'

class Administrador
    def initialize(nombre = "admin")
        @nombre = nombre
        #Son dos variables que controlan el menú
        @gestionando = 0
        @subsistema = 0
        
        #Conecta con la base de datos y nos da la versión que se está usando
        @con = Mysql.new('localhost', 'monopoly', 'monopoly', 'Monopoly')
        
        puts @con.get_server_info
        @rs = @con.query 'SELECT VERSION()'
        puts @rs.fetch_row 

    end
    #---------------------- Subsistema de Tableros ----------------------#
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
        result = @con.query("SELECT numeroCasillas FROM tablero WHERE idTablero = '#{id_tablero}'")
        puts "El tablero #{id_tablero} tiene #{result} casillas y son: "
        result = @con.query("SELECT idCasilla FROM asociada WHERE idTablero = '#{id_tablero}'")
        indice = 1
        result.each do |array|
            array.each do |value|
                puts "\t#{indice}- "+value
                indice += 1
            end
        end
    end

    #---------------------- Subsistema de Casillas ----------------------#
    def insertarCasilla
        #Crea la tabla casilla si no la tenemos ya en el sistema
        @con.query("CREATE TABLE IF NOT EXISTS casilla(idCasilla varchar(20) PRIMARY KEY \
                    ,tipoCasilla varchar(20) \
                    ,precioCompra int, precioVenta int, cuota int \
                        CHECK(tipoCasilla='calle' or tipoCasilla='estacion' or tipoCasilla='efecto' or tipoCasilla='suerte' or tipoCasilla='caja') \
                    ,efectoCasilla varchar(10000));")
        puts 'Inserte el idCasilla que desea agregar'
        id_casilla = gets.chomp
        puts 'Inserte el tipoCasilla que es'
        tipo_casilla = gets.chomp
        if tipo_casilla == "calle"
            puts 'Inserte el precioCompra de la calle'
            precio_compra = gets.chomp
            puts 'Inserte el precioVenta de la calle'
            precio_venta = gets.chomp
            puts 'Inserte la cuota de la calle'
            cuota = gets.chomp
            @con.query("INSERT INTO casilla(idCasilla, precioCompra, precioVenta, cuota, tipoCasilla) \
                            VALUES('#{id_casilla}','#{precio_compra}','#{precio_venta}','#{cuota}', '#{tipo_casilla}')")
        else 
            if tipo_casilla == "efecto"
                puts 'Inserte una descripción del efecto de la dasilla'
                efecto_casilla = gets.chomp
            elsif tipo_casilla == "suerte"
                efecto_casilla = 'Coja una tarjeta de suerte del centro del tablero'
            else
                efecto_casilla = 'Coja una tarjeta de caja del centro del tablero'
            end
            @con.query("INSERT INTO casilla(idCasilla, efectoCasilla, tipoCasilla \
                            VALUES ('#{id_casilla}','#{efecto_casilla}','#{tipo_casilla}')")            
        end
    end
    #Borrado de una casilla de la base de datos
    def borrarCasilla
        puts 'Inserte el idCasilla que desea borrar'
        id_casilla = gets.chomp
        @con.query("DELETE FROM casilla WHERE ('#{id_casilla}' = idCasilla)")
    end
    #Modificación de casilla de la base de datos
    def modificarCasilla
        puts 'Inserte el idCasilla que deasea modificar'
        id_casilla = gets.chomp
        puts "¿Qué desea modificar? \n\t1- Todo \n\t2- PrecioCompra/PrecioVenta/Cuota \n\t3- Efecto \n\t9- Salir"
        modificar = Integer(gets.chomp)
        if modificar == 1
            @con.query("DELETE FROM casilla WHERE ('#{id_casilla}' = idCasilla)")
            self.insertarCasilla
        elsif modificar == 2
            print "PrecioCompra = "
            precio_compra = Integer(gets.chomp)
            print "PrecioVenta = "
            precio_venta = Integer(gets.chomp)
            print "Cuota = "
            cuota = Integer(gets.chomp)
            @con.query("UPDATE casilla SET precioCompra = '#{precio_compra}' \
                                        && precioVenta = '#{precio_venta}' \
                                        && cuota = '#{cuota}' \
                                        WHERE ('#{id_casilla}' = idCasilla)")
        elsif modificar == 3
            print "Efecto : "
            efecto_casilla = gets.chomp
            @con.query("UPDATE casilla SET efecto_casilla = '#{efecto_casilla}' WHERE ('#{id_casilla}' = idCasilla)")
        end
    end
    #Vision de la información de una casilla
    def verCasilla
        puts 'Inserte el idCasilla que desea ver'
        id_casilla = gets.chomp

        result = @con.query("select * from casilla where (idCasilla = '#{id_casilla}') ")
        
        fields = result.fetch_fields
        print "\n" + fields[0].name + "\t" + fields[1].name + "\t" + fields[2].name + "\t" + fields[3].name + "\t" + fields[4].name + "\t" + fields[5].name
        
        result.each_hash do |row|
            print "\n" + row['idCasilla'] + "\t" + row['tipoCasilla'] + "\t" + row['precioCompra'] + "\t" + row['precioVenta'] + "\t" + row['cuota'] + "\t" + row['efectoCasilla'] +"\n"
        end
        #result.each do |array|
         #   array.each do |value|
          #      puts value
           # end
        #end
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
                while @gestionando != 9 do
                    puts "Gestión de Casillas"
                    puts "\t1- Insertar \n\t2- Borrar \n\t3- Modificar \n\t4- Ver \n\t9- Salir"
                    print "Opcion: "
                    @gestionando = Integer(gets.chomp)
                    if @gestionando == 1
                        self.insertarCasilla
                    elsif @gestionando == 2
                        self.borrarCasilla
                    elsif @gestionando == 3
                        self.modificarCasilla
                    elsif @gestionando == 4
                        self.verCasilla
                    end
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

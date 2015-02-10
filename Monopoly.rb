#!/usr/bin/irb

require 'mysql'

$NUM_PARTIDA = 0

class Administrador
    def initialize(nombre = "admin")
        @nombre = nombre
        #Son dos variables que controlan el menú
        @gestionando = 0
        @subsistema = 0

        @sistema = Sistema.new()

        #Conecta con la base de datos y nos da la versión que se está usando
        @con = Mysql.new('localhost', 'monopoly', 'monopoly', 'Monopoly')

        puts @con.get_server_info
        @rs = @con.query 'SELECT VERSION()'
        puts @rs.fetch_row

        #####
        #Creación de tablas en caso de que no existan
        #####

        #Tablero
        @con.query("CREATE TABLE IF NOT EXISTS tablero(idTablero varchar(20) PRIMARY KEY, numeroCasillas int);")

        #Asociada
        @con.query("CREATE TABLE IF NOT EXISTS asociada(idTablero varchar(20) REFERENCES tablero(idTablero) \
        ,idCasilla varchar(20) REFERENCES casilla(idCasilla) \
        ,PRIMARY KEY(idTablero,idCasilla));")

        #Casilla
        @con.query("CREATE TABLE IF NOT EXISTS casilla(idCasilla varchar(20) PRIMARY KEY \
        ,tipoCasilla varchar(20) \
        ,precioCompra int, precioVenta int, cuota int \
        CHECK(tipoCasilla='calle' or tipoCasilla='estacion' or tipoCasilla='efecto' or tipoCasilla='suerte' or tipoCasilla='caja') \
        ,efectoCasilla varchar(10000));")

        #Tarjeta
        @con.query("CREATE TABLE IF NOT EXISTS tarjeta(idTarjeta varchar(20) PRIMARY KEY \
        ,tipoTarjeta varchar(20) \
        ,efectoTarjeta varchar(1000) \
        , CONSTRAINT tipo_tarjeta_valido CHECK(tipoTarjeta='suerte' or tipoTarjeta='caja'));")

        #Partida
        @con.query("CREATE TABLE IF NOT EXISTS partida(idPartida INT PRIMARY KEY \
        ,fecha date NOT NULL \
        ,estado VARCHAR(20) NOT NULL);")

        #PtieneJugador
        @con.query("CREATE TABLE IF NOT EXISTS PtieneJugador(idPartida INT REFERENCES partida(idPartida) \
        ,nick VARCHAR(20) REFERENCES jugador(nick) \
        ,CONSTRAINT clave_primaria PRIMARY KEY (idPartida,nick))")

        #PtieneTablero
        @con.query("CREATE TABLE IF NOT EXISTS PtieneTablero(idPartida INT REFERENCES partida(idPartida) \
        ,idTablero VARCHAR(20) REFERENCES tablero(idTablero) \
        ,CONSTRAINT clave_primaria PRIMARY KEY (idPartida))")

        #PtieneTarjeta
        @con.query("CREATE TABLE IF NOT EXISTS PtieneTarjeta(idPartida INT REFERENCES partida(idPartida) \
        ,idTarjeta VARCHAR(20) REFERENCES tarjeta(idTarjeta) \
        ,CONSTRAINT clave_primaria PRIMARY KEY (idTarjeta))")

        #Posee
        @con.query("CREATE TABLE IF NOT EXISTS posee(idPartida INT REFERENCES partida(idPartida) \
        ,nick VARCHAR(20) REFERENCES jugador(nick) \
        ,idPropiedad int REFERENCES propiedad(idPropiedad) \
        ,CONSTRAINT clave_primaria PRIMARY KEY (idPropiedad));")

    end

    #Función auxiliar para visualizar la primera fila de una consulta
    def visualizarQuery(result)
        fields = result.fetch_fields
        row = result.fetch_row

        puts "\n"

        fields.each_index do |i|
            puts "#{fields[i].name}\t#{row[i]}\n\n"
        end
    end

    def visualizarPosibilidades(table, id)
        result = @con.query("SELECT #{id} FROM #{table}")
        puts "-----"
        result.each do |array|
            array.each_index do |i|
                puts "\t#{i+1}- "+array[i]
            end
        end
        puts "-----"
    end


    #---------------------- Subsistema de Tableros ----------------------#
    def insertarTablero
        puts 'Inserte el idTablero que desea agregar'
        id_tablero = gets.chomp

        @con.query("INSERT INTO tablero(idTablero, numeroCasillas) VALUES('#{id_tablero}', '0');")
    end

    def borrarTablero
        puts 'Inserte el idTablero que desea borrar'
        id_tablero = gets.chomp

        @con.query("DELETE FROM tablero WHERE ('#{id_tablero}' = idTablero)")
    end

    #Asocia una casilla a un tablero
    def asociarCasilla
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

        result = @con.query("SELECT * FROM tablero WHERE idTablero = '#{id_tablero}'").fetch_row
        puts "El tablero #{result[0]} tiene #{result[1]} casillas y son: "

        result = @con.query("SELECT idCasilla FROM asociada WHERE idTablero = '#{id_tablero}'")

        result.each do |array|
            array.each_index do |i|
                puts "\t#{i+1}- "+array[i]
            end
        end
    end

    #---------------------- Subsistema de Casillas ----------------------#
    def insertarCasilla
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
                            VALUES('#{id_casilla}','#{precio_compra}','#{precio_venta}','#{cuota}', '#{tipo_casilla}'")
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
                            VALUES ('#{id_casilla}','#{efecto_casilla}','#{tipo_casilla}'))")
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
        puts 'Las casillas disponibles son las siguientes'
        visualizarPosibilidades("casilla", "idCasilla")

        puts 'Inserte el idCasilla que desea ver'
        id_casilla = gets.chomp

        result = @con.query("select * from casilla where (idCasilla = '#{id_casilla}') ")

        visualizarQuery result
    end

    #---------------------- Subsistema de Tarjetas ----------------------#
    def insertarTarjeta
        puts 'Inserte el idTarjeta que desea agregar'
        id_tarjeta = gets.chomp

        puts 'Inserte el tipoTarjeta que es'
        tipo_tarjeta = gets.chomp

        puts 'Inserte la desripción del efecto de la tarjeta'
        efecto_tarjeta = gets.chomp

        @con.query("INSERT INTO tarjeta(idTarjeta, tipoTarjeta, efectoTarjeta) \
                            VALUES('#{id_tarjeta}','#{tipo_tarjeta}','#{efecto_tarjeta}')")
    end

    def borrarTarjeta
        puts 'Inserte el idTarjeta que desea borrar'
        id_tarjeta = gets.chomp

        @con.query("DELETE FROM tarjeta WHERE ('#{id_tarjeta}' = idTarjeta)")
    end

    def modificarTarjeta
        puts 'Inserte el idTarjeta que desea modificar'
        id_tarjeta = gets.chomp

        puts 'Inserte el nuevo tipo: '
        tipo_tarjeta = gets.chomp

        puts 'Inserte el nuevo efecto de la tarjeta'
        efecto_tarjeta = gets.chomp

        @con.query("UPDATE tarjeta SET tipoTarjeta = '#{tipo_tarjeta}' \
                                        && efectoTarjeta = '#{efecto_tarjeta}' \
                                        WHERE ('#{id_tarjeta}' = idTarjeta)")
    end

    def verTarjeta
        puts 'Inserte el idTarjeta que desea ver'
        id_tarjeta = gets.chomp

        result = @con.query("SELECT * FROM tarjeta where idTarjeta = '#{id_tarjeta}'")

        visualizarQuery result


    end

    #Método que se ocupa del manejo de todas las funcionalidades del administrador
    def gestion
        while @subsistema != 9 do
            puts "Bienvenido Administrador"
            puts "¿Qué desea gestionar? \n\t1- Tablero \n\t2- Casillas \n\t3- Tarjetas \n\t4- Partidas \n\t9- Salir"
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
                while @gestionando != 9 do
                    puts "Gestión de Tarjetas"
                    puts "\t1- Insertar \n\t2- Borrar \n\t3- Modificar \n\t4- Ver \n\t9- Salir"
                    print "Opcion: "
                    @gestionando = Integer(gets.chomp)

                    if @gestionando == 1
                        self.insertarTarjeta
                    elsif @gestionando == 2
                        self.borrarTarjeta
                    elsif @gestionando == 3
                        self.modificarTarjeta
                    elsif @gestionando == 4
                        self.verTarjeta
                    end
                end
                @gestionando = 0
            elsif @subsistema == 4
                while @gestionando != 9 do
                    puts "Gestión de Partidas"
                    puts "\t1- Añadir partida \n\t2- Añadir propiedad jugador \n\t3- Borrar propiedad jugador \n\t9- Salir"
                    print "Opcion: "
                    @gestionando = Integer(gets.chomp)

                    if @gestionando == 1
                        @sistema.añadirPartida
                    elsif @gestionando == 2
                        @sistema.añadirPropiedadJugador
                    elsif @gestionando == 3
                        @sistema.borrarPropiedadJugador
                    end
                end
                @gestionando = 0
            end
        end
    end
end

class Sistema
    def initialize(nombre = 'luck-lord')
        @nombre = nombre

        #Conecta con la base de datos y nos da la versión que se está usando
        @con = Mysql.new('localhost', 'monopoly', 'monopoly', 'Monopoly')

        puts @con.get_server_info
        @rs = @con.query 'SELECT VERSION()'
        puts @rs.fetch_row
    end

    def añadirPartida
        fecha_actual = Time.now

        print 'Jugador 1: '
        id_jugador1 = gets.chomp
        print 'Jugador 2: '
        id_jugador2 = gets.chomp
        print 'Jugador 3: '
        id_jugador3 = gets.chomp
        print 'Jugador 4: '
        id_jugador4 = gets.chomp

        jugadores = [id_jugador1,id_jugador2,id_jugador3,id_jugador4]

        num_partida = @con.query("SELECT MAX(idPartida) FROM partida").fetch_row[0].to_i

        if(num_partida == nil)
            num_partida = 0;
        else
            num_partida += 1
        end

        @con.query("INSERT INTO partida(idPartida,fecha,estado) VALUES('#{num_partida}' \
                                                                      ,'#{fecha_actual}' \
                                                                      ,'partida_nueva')")

        puts "¿HOLA?"
        jugadores.each do |jugador|
            @con.query("INSERT INTO PtieneJugador(idPartida,nick) VALUES('#{num_partida}' \
                                                                        ,'#{jugador}')")
        end
        puts '¿Qué tablero uso?'
        id_tablero = gets.chomp
        @con.query("INSERT INTO PtieneTablero(idPartida,idTablero) VALUES('#{num_partida}' \
                                                                         ,'#{id_tablero}')")
        #Aquí habría que coger una colección aleatoria de tarjetas y añadirlas a la tabla PtieneTarjeta
    end

    def añadirPropiedadJugador
        puts '¿Qué propiedad se ha comprado?'
        id_propiedad = gets.chomp

        puts '¿Qué jugador ha comprado una propiedad? '
        id_jugador = gets.chomp

        @con.query("INSERT INTO posee(idPartida,nick,idPropiedad) VALUES('#{@nombre}','#{id_jugador}','#{id_propiedad}')")
    end

    def borrarPropiedadJugador
        puts '¿Qué propiedad se ha vendido?'
        id_propiedad = gets.chomp

        @con.query("DELETE FROM posee WHERE idPropiedad = '#{id_propiedad}'")
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

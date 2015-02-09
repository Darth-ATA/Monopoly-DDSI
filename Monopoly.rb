#!/usr/bin/irb
require 'mysql'

class Administrador
    #Inserción de un tablero en la base de datos
    def insertarTablero(id_tablero)
        con.query("INSTERT INTO Tablero(idTablero) VALUES('#{id_tablero}')")
    end
    def borrarTablero(id_tablero)
        con.query("DELETE FROM Tablero")
    end
end
begin
    con = Mysql.new 'localhost', 'alejandro', '26036162', 'Monopoly'
    
    gestionando = "vamos"
    subsistema = "vamos"

    puts "En caso de ser un Administrador escriba 1."
    individuo = Integer(gets.chomp)
    if(individuo == 1)
        while(subsistema != "quit")
            puts "Bienvenido Administrador"
            puts "¿Qué desea gestionar? \n\t1- Tablero \n\t2- Casillas \n\t3- Tarjetas"
            print "Opcion: "
            gestionar = Integer(gets.chomp)
            if(gestionar == 1)
                while gestionando != "quit" do
                    puts "Gestión de Tableros"
                    puts "\t1- Insertar \n\t2- Borrar \n\t3- Asociar una casilla a un tablero"
                    print "Opcion: "
                    gestionando = gets.chomp
                end
                gestionando = "vamos"
            elsif(gestionar == 2)
                while gestionando != "quit" do
                    puts "Gestión de Casillas"
                    puts "\t1- Insertar \n\t2- Borrar \n\t3- Modificar"
                    print "Opcion: "
                    gestionando = gets.chomp
                end
                gestionando = "vamos"
            else
                while gestionando != "quit" do
                    puts "Gestión de Tarjetas"
                    puts "\t1- Insertar \n\t2- Borrar \n\t3- Modificar"
                    print "Opcion: "
                    gestionando = gets.chomp
                end
                gestionando = "vamos"
            end
        end
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

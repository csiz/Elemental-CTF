import smtplib  
import atexit

from_address = 'calin.mocanu@gmail.com'

username = input("Enter username: ")
password = input("Enter password: ")
        
server = smtplib.SMTP('smtp.gmail.com:587') 
server.starttls()  
server.login(username,password)

atexit.register(server.quit)
        
    
def Send(to, message):
    if to != '':
        server.sendmail(from_address, to, message)


from flask import Flask, render_template
import pymysql

app = Flask(__name__)

class Database:
    def __init__(self):
        host = "127.0.0.1"
        user = "root"
        password = "somewordpress"
        db = "garland"
        self.con = pymysql.connect(host=host, port=3306, user=user, password=password, db=db, cursorclass=pymysql.cursors.
                                   DictCursor)
        self.cur = self.con.cursor()
    def list_employees(self):
        self.cur.execute("show databases")
        result = self.cur.fetchall()
        return result

@app.route('/')
def employees():
    def db_query():
        db = Database()
        emps = db.list_employees()
        return emps
    res = db_query()
    return render_template('databases.html', result=res, content_type='application/json')

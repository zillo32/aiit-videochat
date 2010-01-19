# _*_ coding: utf-8 _*_
from google.appengine.ext import db, webapp
from google.appengine.ext.webapp.util import run_wsgi_app
import re
import datetime

version = 'Magi system 2009 ver.0.4current(aka Googlecus system)'

# Melchior: 科学者
# Casper: 母
# Balthazar: 女

class Log(db.Model):
    msg = db.StringProperty(required=True)
    room = db.StringProperty(required=True)
    room_id = db.StringProperty(required=True)
    me = db.StringProperty(required=True)
    me_id = db.StringProperty(required=True)
    datetime = db.DateTimeProperty(auto_now_add=True)
#    time = db.StringProperty(required=True)

class Last(db.Model):
    room = db.StringProperty(required=True)
    room_id = db.StringProperty(required=True)
    me = db.StringProperty(required=True)
    me_id = db.StringProperty(required=True)
    datetime = db.DateTimeProperty(auto_now=True)

class  MainHandler(webapp.RequestHandler):
    def write(self, msg, prefix = '[Melchior] '):
#        self.response.out.write(u'<span style="font-family: serif">' + (datetime.datetime.today() + datetime.timedelta(hours=9)).strftime("%H:%M ") + prefix + msg + '</span>' + "\n")
        self.response.out.write(u'<span style="font-family: sans-serif">' + (datetime.datetime.today() + datetime.timedelta(hours=9)).strftime("%H:%M ") + prefix + msg + '</span>' + "\n")
#        self.response.out.write((datetime.datetime.today() + datetime.timedelta(hours=9)).strftime("%H:%M ") + prefix + msg + "\n")

    def write_ml(self, msg, prefix = '[Melchior] '):
        for str in msg.rstrip().split('\n'):
            self.write(str, prefix)

    def twitter(self):
        pass
#        #twitter
#            self.write('はじめまして > me', prefix = "[Melchior] ")
    
    def log(self, room_id, num):
        if num > 100:
            num = 100
        elif num < 1:
            num = 10
        q = Log.gql("WHERE room_id = :1 ORDER BY datetime DESC LIMIT %d" % (num), room_id)
        logs = []
        for l in q:
            logs.append('%s (%s) %s' % ((l.datetime + datetime.timedelta(hours=9)).strftime("%m/%d %H:%M"), l.me, l.msg))

        self.write('last %d in %d logs' % (num, q.count()))
        for str in reversed(logs):
            self.write(str, prefix='> ')
   
    def post(self):
        msg = self.request.get('msg')
        room = self.request.get('room')
        room_id = self.request.get('room_id')
        me = self.request.get('me')
        me_id = self.request.get('me_id')

#        p = re.search(u"\+", msg)
#        if (p):
#            self.write("%2b" + " > " + me, prefix="[Casper] ")

#        if msg[1] == ' ': 
#            self.write("msg[1] is space", prefix="(%s) " % me)

        self.write(msg, prefix="(%s) " % me)

#        self.twitter()

        # auto response & last 
        flag = True
        q = Last.gql("WHERE room_id = :1 and me_id = :2", room_id, me_id)
        if q.count() > 0:
            for last in q:
                diff = (datetime.datetime.today() - last.datetime)
                if diff.days > 0:
                    flag = False
                    self.write(u"ごぶさた。%d日ぶりですね > %s" % (diff.days, me), prefix = "[Casper] ")
#                hours = int((diff.days * 86400 + diff.seconds) / (60 * 60))
#                if hours > 0:
#                    flag = False
#                    self.write(u"ごぶさた。%d時間ぶりですね > %s" % (hours, me), prefix = "[Casper] ")
        else:
            flag = False
            self.write(u'はじめまして > %s' % me, prefix="[Casper] ")
            self.write(u'私は留守番ロボットです。たまに返事しますが無視してください。', prefix="[Casper] ")
            self.write(u'使用法はここみてね > http://pk.aiit.ac.jp/avc/', prefix="[Casper] ")
            last = Last(room=room, room_id=room_id, me=me, me_id=me_id)
        last.put()

        msg = msg.strip()

#        p = re.search(u"(こん(ばん|にち)(は|わ|ハ)|hello|howdy)[^>＞]*[>＞]?\s*(.*)", msg, re.I)
        p = re.search(u"(こん(ばん|にち)(は|わ|ハ)|hello|howdy)", msg, re.I)
        if (p) and flag:
            ret = p.groups()
#            self.write("len: %d" % len(ret), prefix="[Casper] ")
#            self.write("[%s][%s][%s][%s][%s]" % (ret[0], ret[1], ret[2], ret[3], ret[4]), prefix="[Casper] ")

#            self.write(p.group(0) + " > " + me + " > " + p.group(2), prefix="[Casper] ")
            self.write(p.group(0) + " > " + me, prefix="[Casper] ")
        
        elif msg[0] == '#':
            msg = msg[1:].strip().lower()
#            self.write('(' + msg + ")\n")

            if msg == "version":
                self.write(version)

            if msg == u"占い":
                if me == u"風鈴華斬":
                    self.write(u'大凶: 明日は悪いことがあるでしょう > %s' % me, prefix="[Balthazar] ")
                elif me == u"yossy":
                    self.write(u'吉: 明日は嫁の機嫌がいいでしょう > %s' % me, prefix="[Balthazar] ")
                else:
                    self.write(u'大吉: 明日はいいことがあるでしょう♪ > %s' % me, prefix="[Balthazar] ")

            elif msg == "help":
                self.write("----- online manual ----")
                s = u"""#help: これ
#version: バージョン情報の表示
#log: 10行のログ表示
#tail: logと同じ
#tail -n num: num行のログ表示（ただし，numが0以下のときは10，100以上のときは100）
#last: 直近10名の参加者の最終発言時間
#kobito.py: 仕事代行♪
"""
                self.write_ml(s, prefix="> ")

            elif msg == "last":
                q = Last.gql("WHERE room_id = :1 ORDER BY datetime DESC LIMIT 10", room_id)
                last = []
                num = 0
                for l in q:
                    num += 1
                    last.append('%s (%s)' % ((l.datetime + datetime.timedelta(hours=9)).strftime("%m/%d %H:%M"), l.me))
                self.write('last %d users' % num)
                for str in reversed(last):
                    self.write(str, prefix='> ')
            
            elif msg == "log" or msg == "tail":
                self.log(room_id, 10)

            else:
                p = re.search("^tail\s+-(n|-numbers)\s+(-?\d+)$", msg)
                if (p):
                    self.log(room_id, int(p.group(2)))

#            self.response.out.write('[Casper] ' + time.ctime() + "\n")
        else:
            log = Log(msg=msg, room=room, room_id=room_id, me=me, me_id=me_id)
            log.put()
            
def  main():
    application = webapp.WSGIApplication([('/', MainHandler)], debug=True)
    run_wsgi_app(application) 

if  __name__  ==  '__main__':
    main()

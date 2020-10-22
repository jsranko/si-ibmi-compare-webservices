#!/usr/bin/env python3

from bottle import route, run

@route('/', method='GET')
def hello():
    return "Hello from Python"
    
run(host='0.0.0.0', port=44006)
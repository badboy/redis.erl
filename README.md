redis.erl
=========

simple implemenation of a [redis][] library written in [erlang][].

This is my first try with erlang, so no high quality code to expect.

It is untested and has some bugs.

Feel free to fork away and improve it ;)

Usage
-----

First connect is as easy as you think:

    Sock = redis:connect().

This connects to the redis server running on localhost:6379

now you can call the commands:

    1> redis:set(Sock, "foo", "bar").
    ok
    2> redis:keys(Sock).
    ["foo"]
    3> redis:get(Sock, "foo").
    "bar" 
    4> redis:exists(Sock, "bar").
    false
    5> redis:size(Sock).
    1
    6> redis:incr(Sock, "counter").
    1
    7> redis:incr(Sock, "counter").
    2
    8> redis:incrby(Sock, "counter", 3).
    5
    9> ...

Implemented Commands
--------------------

So far the following commands are implemented
(but not fully tested ;))

* KEYS (fails if given DATA size is > 9, pattern matching needs improvement)
* SET
* GET
* EXISTS
* DEL
* TYPE
* SELECT
* TTL
* INCR
* DECR
* INCRBY
* DECRBY
* INFO (parsed into List, but given DATA size is ignored)

according to the [Command Reference][commandreference] there are a lot missing.

What is missing?
----------------

* TESTS!
* implementation of more/all commands
* bug fixes
* TESTS!
* correctly handle bulk responses
* TESTS!


Author
------

Jan-Erik Rediger :: @badboy_


[redis]: http://github.com/antirez/redis/
[erlang]: http://github.com/erlang/otp/
[commandreference]: http://code.google.com/p/redis/wiki/CommandReference

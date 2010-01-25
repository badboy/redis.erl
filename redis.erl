-module(redis).
%-export([]).
-compile(export_all).
-define(DEFAULT_HOST, "127.0.0.1").
-define(DEFAULT_PORT, 6379).
-define(DEFAULT_DB, 0).

connect() ->
    connect(?DEFAULT_HOST, ?DEFAULT_PORT, infinity).

connect(Host, Port) ->
    connect(Host, Port, infinity).

connect(Host, Port, Timeout) ->
    {ok, Sock} = gen_tcp:connect(Host, Port, [binary, {packet, 0}, {active, false}], Timeout),
    Sock.

close(Sock) ->
    ok = gen_tcp:close(Sock).

send(Sock, Data) ->
    %io:format("~s~n", [list_to_binary(Data)]),
    ok = gen_tcp:send(Sock, list_to_binary(Data)),
    {ok,Resp} = gen_tcp:recv(Sock, 0),
    read_reply(Resp).

keys(Sock) ->
    keys(Sock, "*").
keys(Sock, Arg) ->
    ok = gen_tcp:send(Sock, list_to_binary(["keys ",Arg,"\r\n"])),
    {ok,Resp} = gen_tcp:recv(Sock, 0),
    read_reply(Resp).

get(Sock, Key) ->
    [H|_] = send(Sock, ["get ", Key, "\r\n"]),
    H.

set(Sock, Key, Value) ->
    send(Sock, ["set ", Key, " ", integer_to_list(length(Value)), "\r\n", Value, "\r\n"]).

exists(Sock, Key) ->
    case send(Sock, ["exists ", Key, "\r\n"]) of
        1 -> true;
        0 -> false
    end.

del(Sock, Key) ->
    send(Sock, ["del ", Key, "\r\n"]).

type(Sock, Key) ->
    send(Sock, ["type ", Key, "\r\n"]).

size(Sock) ->
    send(Sock, ["dbsize", "\r\n"]).

select(Sock, DB) ->
    send(Sock, ["select ", DB, "\r\n"]).

ttl(Sock, Key) ->
    send(Sock, ["ttl ", Key, "\r\n"]).

incr(Sock, Key) ->
    send(Sock, ["incr ", Key, "\r\n"]).
decr(Sock, Key) ->
    send(Sock, ["decr ", Key, "\r\n"]).
incrby(Sock, Key, Incr) ->
    send(Sock, ["incrby ", Key, " ", integer_to_list(Incr), "\r\n"]).
decrby(Sock, Key, Incr) ->
    send(Sock, ["decrby ", Key, " ", integer_to_list(Incr), "\r\n"]).

info(Sock) ->
    send(Sock, ["info\r\n"]).


% Bulk Reply, prefixed with $ and the Length
read_reply(<<"$",_BulkLen, "\r\n", Rest/binary>>) ->
    Data = remove_tail(Rest),
    string:tokens(binary_to_list(Data), " ");
% Bulk Reply failed (-1)
read_reply(<<"$-1\r\n">>) ->
    [undefined];
% Status Code Reply, + following the String
read_reply(<<"+", Answer/binary>>) ->
    list_to_atom(string:to_lower(binary_to_list(remove_tail(Answer))));
% Error Reply, - followed by error string
% TODO: should throw an error
read_reply(<<"-", Answer/binary>>) ->
    list_to_atom(string:to_lower(binary_to_list(remove_tail(Answer))));
% Integer Reply, : followed by base-10 integer
read_reply(<<":", Answer/binary>>) ->
    list_to_integer(binary_to_list(remove_tail(Answer)));
% FIXME:
% catch everything else (for example response of "info")
% I don't know how to correctly handle
% <<"$363\r\n...\r\n">>
% any ideas/help?
read_reply(<<"$", Rest/binary>>) ->
    [_Size|Tail] = string:tokens(binary_to_list(Rest), "\r\n"),
    lists:map(fun(X) ->
                [Key|Value] = string:tokens(X, ":"),
                {Key,lists:flatten(Value)}
        end, Tail);
read_reply(Resp) ->
    io_lib:format("not implemented: ~s", [Resp]).

remove_tail(Bin) when is_binary(Bin) ->
    {Data, _Tail} = split_binary(Bin, length(binary_to_list(Bin))-2),
    Data;
remove_tail(Bin) when is_list(Bin) ->
    {Data, _Tail} = split_binary(Bin, length(Bin)-2),
    Data.

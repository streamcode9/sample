-module(review).
-behaviour(supervisor).
-behaviour(application).
-compile(export_all).
main(A)    -> mad:main(A).
stop(_)    -> ok.
start()    -> start(normal,[]).
start(_,_) -> case ver() of cow1 -> []; _ ->
                   cowboy:start_clear(http, [{port, port()}],
                      #{ env => #{dispatch => n2o_cowboy2:points()} }),
                   cowboy:start_tls(http, [{port, port()+1}, {certfile, code:priv_dir(sample)++"/ssl/fullchain.pem"}, {keyfile, code:priv_dir(sample)++"/ssl/privkey.pem"}],
                      #{ env => #{dispatch => n2o_cowboy2:points()} })
              end, supervisor:start_link({local,review},review,[]).
init([])   -> kvs:join(), {ok, {{one_for_one, 5, 10}, ?MODULE:(ver())() }}.
ver()      -> application:get_env(n2o,cowboy_spec,cow2).
cow2()     -> [].
cow1()     -> [spec()].
port()     -> application:get_env(n2o,port,8000).
env()      -> [ { env, [ { dispatch, n2o_cowboy:points() } ] } ].
spec()     -> ranch:child_spec(http,100,ranch_tcp,[{port,port()}],cowboy_protocol,env()).
rebar3()   -> {ok,[{_,R,L}]}=file:consult(code:lib_dir(review)++"/ebin/review.app"),
              [ application:start(X) || X <- proplists:get_value(applications,L,[]) ],
              application:start(R).

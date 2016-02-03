%% -------------------------------------------------------------------
%%
%% riakshell application riakshell
%%
%% Copyright (c) 2007-2016 Basho Technologies, Inc.  All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% -------------------------------------------------------------------
-module(riakshell_app).

-behaviour(application).

%% Export for the boot process
-export([
         boot/1
        ]).

%% Application callbacks
-export([
         start/2, 
         stop/1
        ]).

boot([DebugStatus | Rest]) ->
    %% suppress error reporting
    case DebugStatus of
        "debug_off" -> ok = error_logger:tty(false);
        "debug_on" -> ok
    end,
    case Rest of
        [FileName, RunFileAs] when RunFileAs =:= "replay"     orelse
                                   RunFileAs =:= "regression" ->
            gg:format("need to run a file of stuff as a log there ~p ~p~n",
                      [FileName, RunFileAs]);
        [] -> 
            gg:format("do nothing~n");
        Other -> 
            gg:format("Exit invalid args ~p~n", [Other]),
            exit({invalid_args, Other})
    end,
    ok = application:start(riakshell),
    Config = application:get_all_env(riakshell),
    user_drv:start(['tty_sl -c -e', {riakshell_shell, start, [Config]}]).

%%%===================================================================
%%% Application callbacks
%%%===================================================================

start(_StartType, _StartArgs) ->
    case connection_sup:start_link() of
        {ok, Pid} ->
            {ok, Pid};
        Error ->
            Error
                end.

stop(_State) ->
    ok.

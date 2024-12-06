%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% @doc Erlang standard Context
%%% @end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%_* Module declaration ===============================================
-module(context).
-compile({no_auto_import, [size/1]}).

%%%_* Exports ==========================================================
%%%_ * API -------------------------------------------------------------
-export([new/0]).
%% Basics
-export([del/2]).
-export([equal/2]).
-export([get/2]).
-export([get/3]).
-export([get_/2]).
-export([is_empty/1]).
-export([is_key/2]).
-export([keys/1]).
-export([set/3]).
-export([size/1]).
-export([is_context/1]).

-export_type([context/0]).

%%%_* Code =============================================================
%%%_* Types ============================================================
-record(c, {obj :: type()}).
-opaque context() :: #c{}.

-type ctx() :: context().
-type type() :: map().

%%%_* Macros ===========================================================
-define(tag(Obj), #c{obj = Obj}).

%%%_ * API -------------------------------------------------------------
%% Returns true if `Term` is a context
-spec is_context(any()) -> boolean().
is_context(#c{}) -> true;
is_context(_) -> false.

%% Create a new context
-spec new() -> ctx().
new() -> ?tag(maps:new()).

%% Removes the key, if it exists, and its associated value from context
%% and returns a new context without key.
-spec del(ctx(), term()) -> ctx().
del(#c{obj = O}, K) -> ?tag(maps:remove(K, O)).

%% Returns true if ctx and ctx are identical
-spec equal(ctx(), ctx()) -> boolean().
equal(#c{obj = O}, #c{obj = O}) -> true;
equal(#c{obj = O}, #c{obj = O2}) -> lists:sort(maps:to_list(O)) =:= lists:sort(maps:to_list(O2)).

%% Get the value associated with the key form the context
-spec get(ctx(), term()) -> {ok, term()} | {error, notfound}.
get(#c{obj = O}, K) -> maybe_get(O, K).

%% Get the value associated with the key from the context.
%% If key is not found return default value.
-spec get(ctx(), term(), term()) -> term().
get(#c{obj = O}, K, D) -> maybe_get(O, K, D).

%% Same as `get/2` but return the value without tag(`{ok, Val}`).
-spec get_(ctx(), term()) -> term().
get_(#c{obj = O}, K) -> maybe_get_(O, K).

%% Returns true if ctx is empty.
-spec is_empty(ctx()) -> boolean().
is_empty(Ctx) -> 0 =:= size(Ctx).

%% Returns true if key exist in context.
-spec is_key(ctx(), term()) -> boolean().
is_key(#c{obj = O}, K) -> maps:is_key(K, O).

%% Returns all keys associated with context as a list.
-spec keys(ctx()) -> list(term()).
keys(#c{obj = O}) -> maps:keys(O).

%% Upsert the value V for the key K.
-spec set(ctx(), term(), term()) -> ctx().
set(#c{obj = O}, K, V) -> ?tag(maps:put(K, V, O)).

%% Return the number of entries in the context.
-spec size(ctx()) -> non_neg_integer().
size(#c{obj = O}) -> maps:size(O).

%%%_* Private functions ================================================
maybe_get(O, K) ->
    case maps:get(K, O, {error, notfound}) of
        {error, notfound} -> {error, notfound};
        Val -> {ok, Val}
    end.

maybe_get_(O, K) ->
    maybe_get(O, K, {error, notfound}).

maybe_get(O, K, D) ->
    case maybe_get(O, K) of
        {error, notfound} -> D;
        {ok, Val} -> Val
    end.

%%%_* Tests ============================================================
-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

new_test() ->
    ?assertEqual(?tag(maps:new()), new()).

del_test() ->
    ?assertEqual(new(), del(set(new(), key, val), key)),
    ?assertEqual(set(new(), key, val), del(set(new(), key, val), bla)).

equal_test() ->
    ?assertEqual(true, equal(new(), new())),
    ?assertEqual(false, equal(new(), set(new(), k, v))).

get_test() ->
    ?assertEqual({ok, b}, get(set(new(), a, b), a)),
    ?assertEqual({error, notfound}, get(set(new(), a, b), b)),
    ?assertEqual(b, get_(set(new(), a, b), a)),
    ?assertEqual({error, notfound}, get_(set(new(), a, b), b)),
    ?assertEqual(b, get(set(new(), a, b), a, c)),
    ?assertEqual(c, get(new(), b, c)).

is_empty_test() ->
    ?assertEqual(true, is_empty(new())),
    ?assertEqual(false, is_empty(set(new(), a, b))).

is_key_test() ->
    ?assertEqual(false, is_key(new(), a)),
    ?assertEqual(true, is_key(set(new(), a, b), a)).

keys_test() ->
    ?assertEqual([], keys(new())),
    ?assertEqual([a, b], keys(set(set(new(), a, a), b, b))).

size_test() ->
    ?assertEqual(0, size(new())),
    ?assertEqual(2, size(set(set(new(), a, a), b, b))).

-endif.

%%%_* Emacs ============================================================
%%% Local Variables:
%%% allout-layout: t
%%% erlang-indent-level: 2
%%% End

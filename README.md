# Erlang Standard Context [![Build Status](https://travis-ci.org/kivra/context.svg?branch=master)](https://travis-ci.org/kivra/context-erlang)

This is the Erlang Standard Context Package. Context is an opaque carrier of
data. It it not meant to replace Erlang's standard ways of working with data
such as `lists`, `dict`, `maps`. etc.

## Getting Started

When developing applications using Erlang it's sometimes desirable to thread
some sort of opaque Context object to ease in working with but not limited to
caching, tracing and various data to keep local state.

Programs that use Contexts should follow these rules to keep interfaces
consistent across packages:

Do not store Contexts; instead, pass a Context explicitly to each function
that needs it. The Context should be the first parameter, typically named ctx:

```erlang
init() ->
  Ctx = context:new(),
  context:set(Ctx, start_ts, os:timestamp()).

handle_request(Ctx, Arg) ->
  Req = context:get(Ctx, req),
  %% ...
  {ok, Ctx}

terminate(Ctx) ->
  Duration = timer:now_diff(os:timestamp(), context:get(Ctx, start_ts)),
  ok.
```

Use context Values only for request-scoped data that transits processes and
APIs, not for passing optional parameters to functions.

If you update data on the context be sure to return the updated context.
A good pattern for returning context and/or data from functions is:
```erlang
%% Update context and return an updated context.
update_ctx(Ctx0) ->
  Ctx1 = context:set(Ctx0, key, value),
  {ok, Ctx1}.

%% Update context and return an updated context and data.
return_data(Ctx0) ->
  Ctx1 = context:set(Ctx0, key, value),
  Data = <<"...">>,
  {ok, {Ctx1, Data}}.

```

## Dependencies

None

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/kivra/context/tags).
## Authors

* **Kivra** - *Initial work* - [Kivra](https://github.com/Kivra)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

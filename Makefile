#!make

include .env

iex:
	iex -S mix

iex.server:
	iex -S mix phx.server
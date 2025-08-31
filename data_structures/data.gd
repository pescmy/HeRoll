extends Node

# References to main nodes
var player = null
var board = null  # accept TileMap or TileMapLayer
var dice = null

# Optional game state
var turn_count: int = 0
var gold: int = 0

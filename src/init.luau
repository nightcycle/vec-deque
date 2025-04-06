--!strict
-- Services
-- Packages
local Option = require("@pkg/@nightcycle/option")
local Error = require("@pkg/@nightcycle/error")
-- Modules
-- Types
type Option<V> = Option.Option<V>
type Entry<V> = {
	index: number,
	value: V,
}
type VecDequeImpl<V> = {
	__index: VecDequeImpl<V>,
	__tostring: (self: VecDeque<V>) -> string,
	__len: (self: VecDeque<V>) -> number,
	__iter: (self: VecDeque<V>) -> { Entry<V> },
	contains: (self: VecDeque<V>, value: V) -> boolean,
	clear: (self: VecDeque<V>) -> (),
	drain: (self: VecDeque<V>) -> { V },
	extend: (self: VecDeque<V>, slice: { V }) -> (),
	get: (self: VecDeque<V>, index: number) -> Option<V>,
	insert: (self: VecDeque<V>, index: number, value: V) -> (),
	popBack: (self: VecDeque<V>) -> Option<V>,
	popFront: (self: VecDeque<V>) -> Option<V>,
	pushBack: (self: VecDeque<V>, value: V) -> (),
	pushFront: (self: VecDeque<V>, value: V) -> (),
	remove: (self: VecDeque<V>, index: number) -> Option<V>,
	retain: (self: VecDeque<V>, predicate: (value: V) -> boolean) -> (),
	isEmpty: (self: VecDeque<V>) -> boolean,
	append: (self: VecDeque<V>, other: VecDeque<V>) -> (),
	front: (self: VecDeque<V>) -> Option<V>,
	back: (self: VecDeque<V>) -> Option<V>,
	sort: (self: VecDeque<V>, comparator: (a: V, b: V) -> boolean) -> () & (self: VecDeque<V>) -> (),
}
export type VecDeque<V> = typeof(setmetatable(
	{} :: {
		_queue: { V },
	},
	{} :: VecDequeImpl<V>
))
-- Constants
-- Variables
-- References
-- Private Functions
-- Class
local VecDeque = {} :: VecDequeImpl<any>
VecDeque.__index = VecDeque

function VecDeque.__tostring(self: VecDeque<any>): string
	return "VecDeque(" .. Error.displayAsJson(self._queue) .. ")"
end
function VecDeque.__len(self: VecDeque<any>): number
	return #self._queue
end
function VecDeque.__iter(self: VecDeque<any>)
	return ipairs :: any, self._queue
end

function VecDeque:drain(): { any }
	return self._queue
end

function VecDeque:contains(value: any): boolean
	return table.find(self._queue, value) ~= nil
end

function VecDeque:isEmpty(): boolean
	return #self._queue == 0
end

function VecDeque:append(vec: VecDeque<any>)
	for i, v in vec do
		table.insert(self._queue, v)
	end
end

function VecDeque:extend(array: { any })
	for i, v in ipairs(array) do
		table.insert(self._queue, v)
	end
end

function VecDeque:clear()
	table.clear(self._queue)
end

function VecDeque:insert(index: number, value: any)
	assert(
		index >= 1 and index <= #self._queue + 1,
		`insert index {index} out of bounds for vector of size {#self._queue}`
	)
	table.insert(self._queue, index, value)
end

function VecDeque:remove(index: number): any
	assert(
		index >= 1 and index <= #self._queue,
		`remove index {index} out of bounds for vector of size {#self._queue}`
	)
	return table.remove(self._queue, index)
end

function VecDeque:retain(predicate: (value: any) -> boolean)
	local i = 1
	while i <= #self._queue do
		local v = self._queue[i]
		if not predicate(v) then
			table.remove(self._queue, i)
		else
			i += 1
		end
	end
end

function VecDeque:pushBack(value: any)
	table.insert(self._queue, value)
end

function VecDeque:pushFront(value: any)
	table.insert(self._queue, 1, value)
end

function VecDeque:popBack(): Option<any>
	return Option.from(table.remove(self._queue, #self._queue))
end

function VecDeque:popFront(): Option<any>
	return Option.from(table.remove(self._queue, 1))
end

function VecDeque:sort(comparator: ((a: any, b: any) -> boolean)?)
	if comparator then
		table.sort(self._queue, comparator)
	else
		table.sort(self._queue)
	end
end

return {
	empty = function<V>(): VecDeque<V>
		local self = setmetatable({
			_queue = {},
		}, VecDeque)
		table.freeze(self)
		return self
	end,
	from = function<V>(initial: { V })
		local self = setmetatable({
			_queue = table.clone(initial),
		}, VecDeque)
		table.freeze(self)
		return self
	end :: (<V>(initial: { V }?) -> VecDeque<V>) & (<V>() -> VecDeque<V>),
	isVecDeque = function(value: unknown?): boolean
		if typeof(value) == "table" then
			return getmetatable(value :: any) == VecDeque
		end
		return false
	end,
}

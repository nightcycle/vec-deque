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
	-- __index: VecDequeImpl<V>,
	-- __tostring: (self: any) -> string,
	-- __len: (self: any) -> number,
	-- __iter: (self: any) -> { Entry<V> },
	display: (self: any) -> string,
	len: (self: any) -> number,
	contains: (self: any, value: V) -> boolean,
	clear: (self: any) -> (),
	drain: (self: any) -> { V },
	extend: (self: any, slice: { V }) -> (),
	get: (self: any, index: number) -> Option<V>,
	insert: (self: any, index: number, value: V) -> (),
	popBack: (self: any) -> Option<V>,
	popFront: (self: any) -> Option<V>,
	pushBack: (self: any, value: V) -> (),
	pushFront: (self: any, value: V) -> (),
	remove: (self: any, index: number) -> Option<V>,
	retain: (self: any, predicate: (value: V) -> boolean) -> (),
	isEmpty: (self: any) -> boolean,
	append: (self: any, other: VecDeque<V>) -> (),
	front: (self: any) -> Option<V>,
	back: (self: any) -> Option<V>,
	sort: (self: any, comparator: (a: V, b: V) -> boolean) -> () & (self: any) -> (),
	forEach: (self: any, callback: (value: V) -> ()) -> (),
	forEachPair: (self: any, callback: (index: number, value: V) -> ()) -> (),
}
export type VecDeque<V> = VecDequeImpl<V>
-- typeof(setmetatable(
-- 	{} :: {
-- 		_queue: { V },
-- 	},
-- 	{} :: VecDequeImpl<V>
-- ))
-- Constants
-- Variables
-- References
-- Private Functions
-- Class
local VecDeque = {} :: VecDequeImpl<any>
local DeprecatedVecDeque = VecDeque :: any
DeprecatedVecDeque.__index = VecDeque

function DeprecatedVecDeque.__tostring(self): string
	return self:display()
end
function DeprecatedVecDeque.__len(self): number
	return self:len()
end
function DeprecatedVecDeque.__iter(self)
	return ipairs :: any, self._queue
end

function VecDeque:display()
	return "VecDeque(" .. Error.displayAsJson(self._queue) .. ")"
end
function VecDeque:len()
	return #self._queue
end

function VecDeque:forEach(callback: (value: any) -> ())
	for i, value in ipairs(self._queue) do
		callback(value)
	end
end

function VecDeque:forEachPair(callback: (i: any, value: any) -> ())
	for i, value in ipairs(self._queue) do
		callback(i, value)
	end
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
		return self :: any
	end,
	from = function<V>(initial: { V })
		local self = setmetatable({
			_queue = table.clone(initial),
		}, VecDeque)
		table.freeze(self)
		return self :: any
	end :: (<V>(initial: { V }?) -> VecDeque<V>) & (<V>() -> VecDeque<V>),
	isVecDeque = function(value: unknown?): boolean
		if typeof(value) == "table" then
			return getmetatable(value :: any) == VecDeque
		end
		return false
	end,
}


//          Copyright Ferdinand Majerech 2011-2014.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

module dyaml.queue;

import std.container.dlist;

import std.traits : hasMember;

package:

/// Simple queue implemented as a singly linked list with a tail pointer.
///
/// Needed in some D:YAML code that needs a queue-like structure without too much
/// reallocation that goes with an array.
///
struct Queue(T)
if (!hasMember!(T, "__xdtor"))
{

private:
    //// Length of the queue.
    size_t length_;
    //// Doubly-linked list used as queue
    DList!T list;

public:

    /// Returns a forward range iterating over this queue.
    auto range() @safe pure nothrow
    {
        return list;
    }

    /// Push a new item to the queue.
    void push(T item) @safe nothrow
    {
        list.insertFront(item);
        length_++;
    }

    /// Insert a new item putting it to specified index in the linked list.
    void insert(T item, const size_t idx) @safe nothrow
    in
    {
        assert(idx <= length_);
    }
    do
    {
        if (idx == length_)
        {
            list.insertFront(item);
        } else
        {
            auto x = list[];
            foreach (i; 0..idx) {
                x.popBack();
            }
            list.insertAfter(x, item);
        }
        length_++;
    }

    /// Returns: The next element in the queue and remove it.
    T pop()
    in
    {
        assert(!empty, "Trying to pop an element from an empty queue");
    }
    do
    {
        length_--;
        scope(exit) list.removeBack();
        return list.back;
    }

    /// Returns: The next element in the queue.
    ref inout(T) peek() @safe pure nothrow inout
    in
    {
        assert(!empty, "Trying to peek at an element in an empty queue");
    }
    do
    {
        return list.back;
    }

    /// Returns: true of the queue empty, false otherwise.
    bool empty() @safe pure nothrow const
    {
        return list.empty;
    }

    /// Returns: The number of elements in the queue.
    size_t length() @safe pure nothrow const
    {
        return length_;
    }
}

@safe pure nothrow unittest
{
    auto queue = Queue!int();
    assert(queue.empty);
    foreach (i; 0 .. 65)
    {
        queue.push(5);
        assert(queue.pop() == 5);
        assert(queue.empty);
        assert(queue.length_ == 0);
    }

    int[] array = [1, -1, 2, -2, 3, -3, 4, -4, 5, -5];
    foreach (i; array)
    {
        queue.push(i);
    }

    array = 42 ~ array[0 .. 3] ~ 42 ~ array[3 .. $] ~ 42;
    queue.insert(42, 3);
    queue.insert(42, 0);
    queue.insert(42, queue.length);

    int[] array2;
    while (!queue.empty)
    {
        array2 ~= queue.pop();
    }

    assert(array == array2);
}

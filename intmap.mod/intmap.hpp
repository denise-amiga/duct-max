
/*
Copyright (c) 2010 Coranna Howard <me@komiga.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

#ifndef _intmap_HPP_
#define _intmap_HPP_

#include <map>
#include <blitz.h>

typedef std::map<int, BBObject*> intmap;

extern "C" {
	intmap* bmx_intmap_create();
	void bmx_intmap_delete(intmap* imap);
	
	void bmx_intmap_clear(intmap* imap);
	int bmx_intmap_size(intmap const* imap);
	int bmx_intmap_isempty(intmap const* imap);
	int bmx_intmap_contains(intmap const* imap, int key);
	
	void bmx_intmap_remove(intmap* imap, int key);
	void bmx_intmap_set(intmap* imap, int key, BBObject* obj);
	BBObject* bmx_intmap_get(intmap* imap, int key);
	
	BBObject* bmx_intmap_getlastobj(intmap const* imap);
	int bmx_intmap_getlastkey(intmap const* imap);
	
	intmap::iterator* bmx_intmap_iter_first(intmap* imap);
	void bmx_intmap_iter_next(intmap::iterator* iter);
	int bmx_intmap_iter_hasnext(intmap* imap, intmap::iterator const* iter);
	BBObject* bmx_intmap_iter_getobject(intmap::iterator const* iter);
	int bmx_intmap_iter_getkey(intmap::iterator const* iter);
	void bmx_intmap_iter_delete(intmap::iterator* iter);
	
	intmap::reverse_iterator* bmx_intmap_riter_first(intmap* imap);
	void bmx_intmap_riter_next(intmap::reverse_iterator* iter);
	int bmx_intmap_riter_hasnext(intmap* imap, intmap::reverse_iterator const* iter);
	BBObject* bmx_intmap_riter_getobject(intmap::reverse_iterator const* iter);
	int bmx_intmap_riter_getkey(intmap::reverse_iterator const* iter);
	void bmx_intmap_riter_delete(intmap::reverse_iterator* iter);
};

#endif // _intmap_HPP_


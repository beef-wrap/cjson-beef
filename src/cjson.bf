/*
Copyright (c) 2009-2017 Dave Gamble and cJSON contributors

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

using System;
using System.Interop;

namespace cjson;

public static class cjson
{
	typealias char = c_char;
	typealias size_t = uint;

	/* project version */
	const c_int CJSON_VERSION_MAJOR 	= 1;
	const c_int CJSON_VERSION_MINOR 	= 7;
	const c_int CJSON_VERSION_PATCH 	= 18;

	/* cJSON Types: */
	const c_int cJSON_Invalid 		= 0;
	const c_int cJSON_False  		= 1 << 0;
	const c_int cJSON_True   		= 1 << 1;
	const c_int cJSON_NULL   		= 1 << 2;
	const c_int cJSON_Number 		= 1 << 3;
	const c_int cJSON_String 		= 1 << 4;
	const c_int cJSON_Array  		= 1 << 5;
	const c_int cJSON_Object 		= 1 << 6;
	const c_int cJSON_Raw    		= 1 << 7; /* raw json */

	const c_int cJSON_IsReference 		= 256;
	const c_int cJSON_StringIsConst 	= 512;

	/* The cJSON structure: */
	[CRepr]
	public struct cJSON
	{
		/* next/prev allow you to walk array/object chains. Alternatively, use GetArraySize/GetArrayItem/GetObjectItem */
		public cJSON* next;
		public cJSON* prev;
		/* An array or object item will have a child pointer pointing to a chain of the items in the array/object. */
		public cJSON* child;

		/* The type of the item, as above. */
		public c_int type;

		/* The item's string, if type==cJSON_String  and type == cJSON_Raw */
		public char* valuestring;
		/* writing to valueint is DEPRECATED, use cJSON_SetNumberValue instead */
		public c_int valueint;
		/* The item's number, if type==cJSON_Number */
		public double valuedouble;

		/* The item's name string, if this item is the child of, or is in the list of subitems of an object. */
		public char* string;
	}

	[CRepr]
	public struct cJSON_Hooks
	{
		/* malloc/free are CDECL on Windows regardless of the default calling convention of the compiler, so ensure the hooks allow passing those functions directly. */
		function void*(size_t sz) malloc_fn;
		function void(void* ptr) free_fn;
	}

	typealias cJSON_bool = c_int;

	/* returns the version of cJSON as a string */
	[CLink] public static extern  char cJSON_Version();

	/* Supply malloc, realloc and free functions to cJSON */
	[CLink] public static extern void cJSON_InitHooks(cJSON_Hooks* hooks);

	/* Memory Management: the caller is always responsible to free the results from all variants of cJSON_Parse (with cJSON_Delete) and cJSON_Print (with stdlib free, cJSON_Hooks.free_fn, or cJSON_free as appropriate). The exception is cJSON_PrintPreallocated, where the caller has full responsibility of the buffer. */
	/* Supply a block of JSON, and this returns a cJSON object you can interrogate. */
	[CLink] public static extern cJSON* cJSON_Parse(char* value);
	[CLink] public static extern cJSON* cJSON_ParseWithLength(char* value, size_t buffer_length);
	/* ParseWithOpts allows you to require (and check) that the JSON is null terminated, and to retrieve the pointer to the final byte parsed. */
	/* If you supply a ptr in return_parse_end and parsing fails, then return_parse_end will contain a pointer to the error so will match cJSON_GetErrorPtr(). */
	[CLink] public static extern cJSON* cJSON_ParseWithOpts(char* value, char** return_parse_end, cJSON_bool require_null_terminated);
	[CLink] public static extern cJSON* cJSON_ParseWithLengthOpts(char* value, size_t buffer_length, char** return_parse_end, cJSON_bool require_null_terminated);

	/* Render a cJSON entity to text for transfer/storage. */
	[CLink] public static extern char* cJSON_Print(cJSON* item);
	/* Render a cJSON entity to text for transfer/storage without any formatting. */
	[CLink] public static extern char* cJSON_PrintUnformatted(cJSON* item);
	/* Render a cJSON entity to text using a buffered strategy. prebuffer is a guess at the final size. guessing well reduces reallocation. fmt=0 gives unformatted, =1 gives formatted */
	[CLink] public static extern char* cJSON_PrintBuffered(cJSON* item, c_int prebuffer, cJSON_bool fmt);
	/* Render a cJSON entity to text using a buffer already allocated in memory with given length. Returns 1 on success and 0 on failure. */
	/* NOTE: cJSON is not always 100% accurate in estimating how much memory it will use, so to be safe allocate 5 bytes more than you actually need */
	[CLink] public static extern cJSON_bool cJSON_PrintPreallocated(cJSON* item, char* buffer, c_int length, cJSON_bool format);
	/* Delete a cJSON entity and all subentities. */
	[CLink] public static extern void cJSON_Delete(cJSON* item);

	/* Returns the number of items in an array (or object). */
	[CLink] public static extern c_int cJSON_GetArraySize(cJSON* array);
	/* Retrieve item number "index" from array "array". Returns NULL if unsuccessful. */
	[CLink] public static extern cJSON* cJSON_GetArrayItem(cJSON* array, c_int index);
	/* Get item "string" from object. Case insensitive. */
	[CLink] public static extern cJSON* cJSON_GetObjectItem(cJSON* object, char* string);
	[CLink] public static extern cJSON* cJSON_GetObjectItemCaseSensitive(cJSON* object, char*  string);
	[CLink] public static extern cJSON_bool cJSON_HasObjectItem(cJSON* object, char* string);
	/* For analysing failed parses. This returns a pointer to the parse error. You'll probably need to look a few chars back to make sense of it. Defined when cJSON_Parse() returns 0. 0 when cJSON_Parse() succeeds. */
	[CLink] public static extern  char cJSON_GetErrorPtr();

	/* Check item type and return its value */
	[CLink] public static extern char cJSON_GetStringValue(cJSON* item);
	[CLink] public static extern double cJSON_GetNumberValue(cJSON* item);

	/* These functions check the type of an item */
	[CLink] public static extern cJSON_bool cJSON_IsInvalid(cJSON* item);
	[CLink] public static extern cJSON_bool cJSON_IsFalse(cJSON* item);
	[CLink] public static extern cJSON_bool cJSON_IsTrue(cJSON* item);
	[CLink] public static extern cJSON_bool cJSON_IsBool(cJSON* item);
	[CLink] public static extern cJSON_bool cJSON_IsNull(cJSON* item);
	[CLink] public static extern cJSON_bool cJSON_IsNumber(cJSON* item);
	[CLink] public static extern cJSON_bool cJSON_IsString(cJSON* item);
	[CLink] public static extern cJSON_bool cJSON_IsArray(cJSON* item);
	[CLink] public static extern cJSON_bool cJSON_IsObject(cJSON* item);
	[CLink] public static extern cJSON_bool cJSON_IsRaw(cJSON* item);

	/* These calls create a cJSON item of the appropriate type. */
	[CLink] public static extern cJSON* cJSON_CreateNull();
	[CLink] public static extern cJSON* cJSON_CreateTrue();
	[CLink] public static extern cJSON* cJSON_CreateFalse();
	[CLink] public static extern cJSON* cJSON_CreateBool(cJSON_bool boolean);
	[CLink] public static extern cJSON* cJSON_CreateNumber(double num);
	[CLink] public static extern cJSON* cJSON_CreateString(char* string);
	/* raw json */
	[CLink] public static extern cJSON* cJSON_CreateRaw(char* raw);
	[CLink] public static extern cJSON* cJSON_CreateArray();
	[CLink] public static extern cJSON* cJSON_CreateObject();

	/* Create a string where valuestring references a string so
	* it will not be freed by cJSON_Delete */
	[CLink] public static extern cJSON* cJSON_CreateStringReference(char* string);
	/* Create an object/array that only references it's elements so
	* they will not be freed by cJSON_Delete */
	[CLink] public static extern cJSON* cJSON_CreateObjectReference(cJSON* child);
	[CLink] public static extern cJSON* cJSON_CreateArrayReference(cJSON* child);

	/* These utilities create an Array of count items.
	* The parameter count cannot be greater than the number of elements in the number array, otherwise array access will be out of bounds.*/
	[CLink] public static extern cJSON* cJSON_CreateIntArray(int* numbers, c_int count);
	[CLink] public static extern cJSON* cJSON_CreateFloatArray(float* numbers, c_int count);
	[CLink] public static extern cJSON* cJSON_CreateDoubleArray(double* numbers, c_int count);
	[CLink] public static extern cJSON* cJSON_CreateStringArray(char** strings, c_int count);

	/* Append item to the specified array/object. */
	[CLink] public static extern cJSON_bool cJSON_AddItemToArray(cJSON* array, cJSON* item);
	[CLink] public static extern cJSON_bool cJSON_AddItemToObject(cJSON* object, char* string, cJSON* item);
	/* Use this when string is definitely  (i.e. a literal, or as good as), and will definitely survive the cJSON object.
	* WARNING: When this function was used, make sure to always check that (item->type & cJSON_StringIs) is zero before
	* writing to `item->string` */
	[CLink] public static extern cJSON_bool cJSON_AddItemToObjectCS(cJSON* object, char* string, cJSON* item);
	/* Append reference to item to the specified array/object. Use this when you want to add an existing cJSON to a new cJSON, but don't want to corrupt your existing cJSON. */
	[CLink] public static extern cJSON_bool cJSON_AddItemReferenceToArray(cJSON* array, cJSON* item);
	[CLink] public static extern cJSON_bool cJSON_AddItemReferenceToObject(cJSON* object, char* string, cJSON* item);

	/* Remove/Detach items from Arrays/Objects. */
	[CLink] public static extern cJSON* cJSON_DetachItemViaPointer(cJSON* parent, cJSON*  item);
	[CLink] public static extern cJSON* cJSON_DetachItemFromArray(cJSON* array, c_int which);
	[CLink] public static extern void cJSON_DeleteItemFromArray(cJSON* array, c_int which);
	[CLink] public static extern cJSON* cJSON_DetachItemFromObject(cJSON* object, char* string);
	[CLink] public static extern cJSON* cJSON_DetachItemFromObjectCaseSensitive(cJSON* object, char* string);
	[CLink] public static extern void cJSON_DeleteItemFromObject(cJSON* object, char* string);
	[CLink] public static extern void cJSON_DeleteItemFromObjectCaseSensitive(cJSON* object, char* string);

	/* Update array items. */
	[CLink] public static extern cJSON_bool cJSON_InsertItemInArray(cJSON* array, c_int which, cJSON* newitem); /* Shifts pre-existing items to the right. */
	[CLink] public static extern cJSON_bool cJSON_ReplaceItemViaPointer(cJSON* parent, cJSON* item, cJSON* replacement);
	[CLink] public static extern cJSON_bool cJSON_ReplaceItemInArray(cJSON* array, c_int which, cJSON* newitem);
	[CLink] public static extern cJSON_bool cJSON_ReplaceItemInObject(cJSON* object, char* string, cJSON* newitem);
	[CLink] public static extern cJSON_bool cJSON_ReplaceItemInObjectCaseSensitive(cJSON* object, char* string, cJSON* newitem);

	/* Duplicate a cJSON item */
	[CLink] public static extern cJSON* cJSON_Duplicate(cJSON* item, cJSON_bool recurse);
	/* Duplicate will create a new, identical cJSON item to the one you pass, in new memory that will
	* need to be released. With recurse!=0, it will duplicate any children connected to the item.
	* The item->next and ->prev pointers are always zero on return from Duplicate. */
	/* Recursively compare two cJSON items for equality. If either a or b is NULL or invalid, they will be considered unequal.
	* case_sensitive determines if object keys are treated case sensitive (1) or case insensitive (0) */
	[CLink] public static extern cJSON_bool cJSON_Compare(cJSON*  a, cJSON*   b, cJSON_bool case_sensitive);

	/* Minify a strings, remove blank characters(such as ' ', '\t', '\r', '\n') from strings.
	* The input pointer json cannot point to a read-only address area, such as a string ant, 
	* but should point to a readable and writable address area. */
	[CLink] public static extern void cJSON_Minify(char* json);

	/* Helper functions for creating and adding items to an object at the same time.
	* They return the added item or NULL on failure. */
	[CLink] public static extern cJSON* cJSON_AddNullToObject(cJSON* object, char* name);
	[CLink] public static extern cJSON* cJSON_AddTrueToObject(cJSON* object, char* name);
	[CLink] public static extern cJSON* cJSON_AddFalseToObject(cJSON* object, char* name);
	[CLink] public static extern cJSON* cJSON_AddBoolToObject(cJSON* object, char* name, cJSON_bool boolean);
	[CLink] public static extern cJSON* cJSON_AddNumberToObject(cJSON* object, char* name, double number);
	[CLink] public static extern cJSON* cJSON_AddStringToObject(cJSON* object, char* name, char* string);
	[CLink] public static extern cJSON* cJSON_AddRawToObject(cJSON* object, char* name, char* raw);
	[CLink] public static extern cJSON* cJSON_AddObjectToObject(cJSON* object, char* name);
	[CLink] public static extern cJSON* cJSON_AddArrayToObject(cJSON* object, char* name);

	/* When assigning an integer value, it needs to be propagated to valuedouble too. */
	//#define cJSON_SetIntValue(object, number) ((object) ? (object)->valueint = (object)->valuedouble = (number) : (number))
	/* helper for the cJSON_SetNumberValue macro */
	[CLink] public static extern double cJSON_SetNumberHelper(cJSON* object, double number);
	//#define cJSON_SetNumberValue(object, number) ((object != NULL) ? cJSON_SetNumberHelper(object, (double)number) : (number))
	/* Change the valuestring of a cJSON_String object, only takes effect when type of object is cJSON_String */
	[CLink] public static extern char cJSON_SetValuestring(cJSON* object, char* valuestring);

	// /* If the object is not a boolean type this does nothing and returns cJSON_Invalid else it returns the new type*/
	// #define cJSON_SetBoolValue(object, boolValue) ( \
	// 	(object != NULL && ((object)->type & (cJSON_False|cJSON_True))) ? \
	// 	(object)->type=((object)->type &(~(cJSON_False|cJSON_True)))|((boolValue)?cJSON_True:cJSON_False) : \
	// 	cJSON_Invalid\
	// )

	/* Macro for iterating over an array or object */
	// #define cJSON_ArrayForEach(element, array) for(element = (array != NULL) ? (array)->child : NULL; element != NULL; element = element->next)

	/* malloc/free objects using the malloc/free functions that have been set with cJSON_InitHooks */
	[CLink] public static extern void cJSON_malloc(size_t size);
	[CLink] public static extern void cJSON_free(void* object);
}
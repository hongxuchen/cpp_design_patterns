## cmakepp 
##
## An enhancement suite for CMake
## 
##
## This file is the entry point for cmakepp. If you want to use the functions 
## just include this file.
##
## it can also be used as a module file with cmake's find_package() 
cmake_minimum_required(VERSION 2.8.7)
get_property(is_included GLOBAL PROPERTY oocmake_include_guard)
if(is_included)
  _return()
endif()
set_property(GLOBAL PROPERTY oocmake_include_guard true)
cmake_policy(SET CMP0007 NEW)
cmake_policy(SET CMP0012 NEW)
cmake_policy(SET CMP0053 OLD)
cmake_policy(SET CMP0054 OLD)
# installation dir of oocmake
set(oocmake_base_dir "${CMAKE_CURRENT_LIST_DIR}")
# include functions needed for initializing oocmake
include(CMakeParseArguments)
# get temp dir which is needed by a couple of functions in oocmake
set(oocmake_tmp_dir "$ENV{TMP}")
if(NOT oocmake_tmp_dir)
	set(oocmake_tmp_dir "${CMAKE_CURRENT_LIST_DIR}/tmp")
endif()
file(TO_CMAKE_PATH "${oocmake_tmp_dir}" oocmake_tmp_dir)
# dummy function which is overwritten and in this form just returns the temp_dir
function(oocmake_config key)
	return("${oocmake_tmp_dir}")
endfunction()
## includes all cmake files of oocmake 




  ## log function
  ##  --error    flag indicates that errors occured
  ##  --warning  flag indicates warnings
  ##  --info     flag indicates a info output
  ##  --debug    flag indicates a debug output
  ## 
  ##  --error-code <code> 
  ##  --level <n> 
  ##  --push <section> depth+1
  ##  --pop <section>  depth-1
  function(log)

    set(args ${ARGN})
    list_extract_flag(args --warning)
    list_extract_flag(args --info)
    list_extract_flag(args --debug)
    list_extract_flag(args --error)
    ans(is_error)
    list_extract_labelled_value(args --level)
    list_extract_labelled_value(args --push)
    list_extract_labelled_value(args --pop)
    list_extract_labelled_value(args --error-code)
    ans(error_code)
    map_new()
    ans(entry)
    list_pop_front(args)
    ans(message)
    map_format("${message}")
    ans(message)
    map_set(${entry} message ${message})
    map_set(${entry} args this ${args})
    map_set(${entry} function ${member_function})
    map_set(${entry} error_code ${error_code})
    set(type)
    if(is_error OR NOT error_code STREQUAL "")
      set(type error)
    endif()
    
    map_set(${entry} type ${type})
    ref_append(log_record ${entry})
  endfunction()

  function(log_record_start)
  endfunction()
  function(log_record_end)
  endfunction()

  function(log_record_clear)
    ref_set(log_record)
  endfunction()

  function(log_last_error_entry)
    ref_get(log_record)
    ans(log_record)
    set(entry)
    while(true)
      if(NOT log_record)
        break()
      endif()
      list_pop_back(log_record)
      ans(entry)

      map_tryget(${entry} type)
      ans(type)
      if(type STREQUAL "error")
        break()
      endif()
    endwhile()
    return_ref(entry)
  endfunction()


  function(log_last_error_message)
    log_last_error_entry()
    ans(entry)
    if(NOT entry)
      return()
    endif()

    map_tryget(${entry} message)
    ans(message)


    return_ref(message)
  endfunction()

  function(log_last_error_print)
    log_last_error_entry()
    ans(entry)
    if(NOT entry)
      return()
    endif()

    message(FORMAT "Error in {entry.function}: {entry.message}")
    return()
  endfunction()




## removes the specified timer
function(timer_delete id)
  map_remove(__timers "${id}")
  return()
endfunction()





## starts a timer identified by id
## 
function(timer_start id)
  map_set_hidden(__timers __prejudice 0)

  # actual implementation of timer_start
  function(timer_start id)
    return_reset()      
    millis()
    ans(millis)
    map_set(__timers ${id} ${millis})
  endfunction()



  ## this is run the first time a timer is started: 
  ## it calculates a prejudice value 
  ## (the time it takes from timer_start to timer_elapsed to run)
  ## this prejudice value is then subtracted everytime elapse is run
  ## thus minimizing the error

  #foreach(i RANGE 0 3)
    timer_start(initial)  
    timer_elapsed(initial)
    ans(prejudice)

    map_tryget(__timers __prejudice)
    ans(pre)
    math(EXPR prejudice "${prejudice} + ${pre}")
    map_set_hidden(__timers __prejudice ${prejudice})
  #endforeach()


  timer_delete(initial)


  return_reset()
  timer_start("${id}")
endfunction()




# returns the time elapsed since timer identified by id was started
function(timer_elapsed id)      
  millis()
  ans(now)
  map_get(__timers ${id})
  ans(then)
  # so this has to be done because cmake can't handle numbers which are too large
  string_trim_to_difference(then now)
  map_tryget(__timers __prejudice)      
  ans(prejudice)
  math(EXPR elapsed "${now} - ${then} - ${prejudice}")
  math_max(${elapsed} 0)
  ans(elapsed)
  return("${elapsed}")
endfunction()




## prints elapsed time for timer identified by id
function(timer_print_elapsed id)
  timer_elapsed("${id}")
  ans(elapsed)
  message("${id}: ${elapsed} ms")
  return()
endfunction()





## prints the elapsed time for all known timer
function(timers_print_all)
  timers_get()
  ans(timers)
  foreach(timer ${timers})
    timer_print_elapsed("${timer}")
  endforeach()  
  return()
endfunction()




## returns the list of known timers
function(timers_get)
  map_keys(__timers)
  ans(timers)
  return_ref(timers)
endfunction()





 function(propref_isvalid propref)
    string_split_at_last(ref prop "${propref}" ".")
    ref_isvalid("${ref}")
    ans(isref)
    if(NOT isref)
      return(false)
    endif()
    obj_has("${ref}" "${prop}")
    ans(has_prop)
    if(NOT has_prop)
      return(false)

    endif()
    return(true)
  endfunction()





  function(propref_get_key)
    string_split_at_last(ref prop "${propref}" ".")
    return_ref(prop)
  endfunction()
  
 





  function(propref_get_ref)
    string_split_at_last(ref prop "${propref}" ".")
    return_ref(ref)
  endfunction()





  ## reads the specified value from the windows registry  
  function(reg_read_value key value_name)
    reg_query_values("${key}")
    ans(res)
    map_tryget(${res} "${value_name}")
    ans(res)
    
    return_ref(res)
  endfunction()






  ## sets the specified windows registry value 
  ## value may contain semicolons
  function(reg_write_value key value_name value)
    string_semicolon_encode("${value}")
    ans(value)
    string(REPLACE / \\ key "${key}")
    set(type REG_SZ)
    reg(add "${key}" /v "${value_name}" /t "${type}" /f /d "${value}" --return-code)
    ans(error)
    if(error)
      return(false)
    endif()
    return(true)
  endfunction()









  ## removes the specified value from the registry value
function(reg_remove_value key value_name)
  reg_read_value("${key}" "${value_name}")
  ans(values)

  list_remove(values ${ARGN})
  reg_write_value("${key}" "${value_name}" "${values}")

  return()

endfunction()






  ## removes all duplicat values form the specified registry value
  function(reg_remove_duplicate_values key value_name)
    reg_read_value("${key}" "${value_name}")
    ans(values)
    list(REMOVE_DUPLICATES values)
    reg_write_value("${key}" "${value_name}" "${values}")
    return()
  endfunction()







  ## parses the result of reg(query )call
  ## returns an reg entry object:
  ## {
  ##   "value_name":registry value name
  ##   "key":registry key
  ##   "value":value of the entry if it exists
  ##   "type": registry value type (ie REG_SZ) or KEY if its a key
  ## }
  function(reg_entry_parse query line)
      if("${line}" MATCHES "^    ([^ ]+)")
        set(regex "^    ([^ ]+)    ([^ ]+)    (.*)")
        string(REGEX REPLACE "${regex}" "\\1" value_name "${line}")
        string(REGEX REPLACE "${regex}" "\\2" type "${line}")
        string(REGEX REPLACE "${regex}" "\\3" value "${line}")
        string_semicolon_decode("${value}")
        ans(value)
        
      else()
        set(key "${query}")
        set(type "KEY")
        set(value "")
        set(value_name "")
      endif()
      map_capture_new(key value_name type value)
      return_ans()
  endfunction()







  ## returns a map contains all the values in the specified registry key
  function(reg_query_values key)
    reg_query("${key}")
    ans(entries)
    map_new()
    ans(res)
    foreach(entry ${entries})
      scope_import_map(${entry})
      if(NOT "${value}_" STREQUAL "_")        
        map_set("${res}" "${value_name}" "${value}")
      endif()
    endforeach()
    return_ref(res)
  endfunction()







  ## appends a value to the specified windows registry value
  function(reg_append_value key value_name)
    reg_read_value("${key}" "${value_name}")
    ans(data)
    set(data "${data};${ARGN}")
    reg_write_value("${key}" "${value_name}" "${data}")
    return_ref(data)
  endfunction()







  ## queryies the registry for the specified key
  ## returns a list of entries containing all direct child elements
  function(reg_query key)
    string(REPLACE / \\ key "${key}")
    reg(query "${key}" --result)
    ans(res)

    map_tryget(${res} output)
    ans(output)


    map_tryget(${res} result)
    ans(error)

    if(error)
      return()
    endif()
    
    string_semicolon_encode("${output}")
    ans(output)
    string(REPLACE "\n" ";" lines ${output})

    set(entries)
    foreach(line ${lines})
      reg_entry_parse("${key}" "${line}")
      ans(res)
      if(res)
        list(APPEND entries ${res})
      endif()
    endforeach()

    return_ref(entries)
  endfunction()





  ### returns true if the registry value contains the specified value
  function(reg_contains_value key value_name value)
    reg_read_value("${key}" "${value_name}")
    ans(values)
    list_contains(values "${value}")
    return_ans()
  endfunction()







  ## appends all specified values to registry value if they are not contained already
  function(reg_append_if_not_exists key value_name)
    reg_read_value("${key}" "${value_name}")
    ans(values)
    set(added_values)
    foreach(arg ${ARGN})
      list_contains(values "${arg}")
      ans(res)
      if(NOT res) 
        list(APPEND values "${arg}")
        list(APPEND added_values "${arg}")
      endif()
    endforeach()

    string_semicolon_decode("${values}")
    ans(values)
    reg_write_value("${key}" "${value_name}" "${values}")
    return_ref(added_values)
  endfunction()








  ## access to the windows reg command
  function(reg)
    if(NOT WIN32)
      message(FATAL_ERROR "reg is not supported on non-windows platforms")
    endif()
    wrap_executable("reg" "REG")
    reg(${ARGN})
    return_ans()
  endfunction()





  ## prepends a value to the specified windows registry value
  function(reg_prepend_value key value_name)
    reg_read_value("${key}" "${value_name}")
    ans(data)
    set(data "${ARGN};${data}")
    reg_write_value("${key}" "${value_name}" "${data}")
    return_ref(data)
  endfunction()







  ## removes the specified value from the windows registry
  function(reg_delete_value key valueName)
    string(REPLACE / \\ key "${key}")
    reg(delete "${key}" /v "${valueName}" /f --return-code)
    ans(error)
    if(error)
      return(false)
    else()
      return(true)
    endif()
  endfunction()





## if the beginning of the str_name is a delimited string
## the undelimited string is returned  and removed from str_name
## you can specify the delimiter (default is doublequote "")
## you can also specify begin and end delimiter 
## the delimiters may only be one char 
## the delimiters are removed from the result string
## escaped delimiters are unescaped
function(string_take_delimited __string_take_delimited_string_ref )
  regex_delimited_string(${ARGN})
  ans(__string_take_delimited_regex)
  string_take_regex(${__string_take_delimited_string_ref} "${__string_take_delimited_regex}")
  ans(__string_take_delimited_match)
  if(NOT __string_take_delimited_match)
    return()
  endif()
  set("${__string_take_delimited_string_ref}" "${${__string_take_delimited_string_ref}}" PARENT_SCOPE)

  # removes the delimiters
  string_slice("${__string_take_delimited_match}" 1 -2)
  ans(res)
  # unescape string
  string(REPLACE "\\${delimiter_end}" "${delimiter_end}" res "${res}")
  return_ref(res) 
endfunction()






# normalizes the index of str (negativ indices are transformed into positive onces)
function(string_normalize_index str index)

  set(idx ${index})
  string(LENGTH "${str}" length)
  if(${idx} LESS 0)
    math(EXPR idx "${length} ${idx} + 1")
  endif()
  if(${idx} LESS 0)
    #message(WARNING "index out of range: ${index} (${idx}) length of string '${str}': ${length}")
    return(-1)
  endif()

  if(${idx} GREATER ${length})
    #message(WARNING "index out of range: ${index} (${idx}) length of string '${str}': ${length}")
    return(-1)
  endif()
  return(${idx})
endfunction()




# encodes an empty element
function(string_encode_empty str)
  if("_${str}" STREQUAL "_")
    return("↔")
  endif()
  return_ref(str)
endfunction()





## escapes a string to be delimited
## by the the specified delimiters
function(string_encode_delimited str)
    delimiters(${ARGN})
    ans(ds)
    list_pop_front(ds)
    ans(delimiter_begin)
    list_pop_front(ds)
    ans(delimiter_end)

    string(REPLACE \\ \\\\ str "${str}" )
    string(REPLACE "${delimiter_end}" "\\${delimiter_end}" str "${str}" )
    set(str "${delimiter_begin}${str}${delimiter_end}")
    return_ref(str)
endfunction()





# escapes chars used by regex
  function(string_regex_escape str)
    string(REGEX REPLACE "(\\/|\\]|\\.|\\[|\\*)" "\\\\\\1" str "${str}")
    return_ref(str)
  endfunction()




# encodes a string list so that it can be correctly stored and retrieved
function(string_encode_list str)
  string_semicolon_encode("${str}")
  ans(str)
  string_encode_bracket("${str}")
  ans(str)
  string_encode_empty("${str}")
return_ans()
endfunction()




function(string_trim str)
  string(STRIP "${str}" str)
  return_ref(str)
endfunction()




# replaces first occurence of stirng_search with string_replace in string_input
function(string_replace_first  string_search string_replace string_input)
	string(FIND "${string_input}" "${string_search}" index)
	if("${index}" LESS "0")
		return_ref(string_input)
	endif()
	string(LENGTH "${string_search}" search_length)
	string(SUBSTRING "${string_input}" "0" "${index}" part1)
	math(EXPR index "${index} + ${search_length}")
	string(SUBSTRING "${string_input}" "${index}" "-1" part2)
	set(res "${part1}${string_replace}${part2}")
	return_ref(res)
endfunction()




# returns the character @ index of input string
# negative values less than -1 are translated into length - |index|
function(string_char_at index input)
  string(LENGTH "${input}" len)
  string_normalize_index("${input}" ${index})
  ans(index)
  if("${index}" LESS 0 OR ${index} EQUAL "${len}" OR ${index} GREATER ${len}) 
    return()
  endif()
  string(SUBSTRING "${input}" ${index} 1 res)
  return_ref(res)

endfunction()




# parses delimiters and retruns a list of length 2
# [delimiter_begin, delimiter_end]
  function(delimiters)
    set(delimiters ${ARGN})


    if("${delimiters}_" STREQUAL "_")
      set(delimiters \")
    endif()



    list_pop_front(delimiters)
    ans(delimiter_begin)


    if("${delimiter_begin}" MATCHES ..)
      string(REGEX REPLACE "(.)(.)" "\\2" delimiter_end "${delimiter_begin}")
      string(REGEX REPLACE "(.)(.)" "\\1" delimiter_begin "${delimiter_begin}")
    else()
      list_pop_front(delimiters)
      ans(delimiter_end)
    endif()

    
    if("${delimiter_end}_" STREQUAL "_")
      set(delimiter_end "${delimiter_begin}")
    endif()

    return(${delimiter_begin} ${delimiter_end})
  endfunction()




# transforms the specifiedstring to lower case
function(string_tolower str)
  string(TOLOWER "${str}" str)
  return_ref(str)
endfunction()




# splits a string by regex storing the resulting list in ${result}
#todo: this should also handle strings containing 
function(string_split  string_subject split_regex)
	string(REGEX REPLACE ${split_regex} ";" res "${string_subject}")
  return_ref(res)
endfunction()






  function(string_append_line_indented str_ref what)
    indent("${what}" ${ARGN})
    ans(indented)
    set("${str_ref}" "${${str_ref}}${indented}\n" PARENT_SCOPE)
  endfunction()





# decodes encoded brakcets in a string
function(string_decode_bracket str)
    string(ASCII 29 bracket_open)
    string(ASCII 28 bracket_close)
      string(REPLACE "${bracket_open}" "["  str "${str}") 
      string(REPLACE "${bracket_close}" "]"  str "${str}")
      return_ref(str)

endfunction()





## returns true if the string is a integer (number)
## does not match non integers
function(string_isnumeric str)
  if("_${str}" MATCHES "^_[0-9]+$")
    return(true)
  endif()
  return(false)
endfunction()




# decodes an encoded empty string
function(string_decode_empty str) 
  if("${str}" STREQUAL "↔")
    return("")
  endif()
  return_ref(str)
endfunction()




# removes the beginning of a string
function(string_remove_beginning original beginning)
  string(LENGTH "${beginning}" len)
  string(SUBSTRING "${original}" ${len} -1 original)
  return_ref(original)
endfunction()




## removes the beginning of the string that matches
## from ref lhs and ref rhs
function(string_trim_to_difference lhs rhs)
  string_overlap("${${lhs}}" "${${rhs}}")
  ans(overlap)
  string_take(${lhs} "${overlap}")
  string_take(${rhs} "${overlap}")
  set("${lhs}" "${${lhs}}" PARENT_SCOPE)
  set("${rhs}" "${${rhs}}" PARENT_SCOPE)
endfunction()





# splits input at first occurence of separator into part a  and partb
function(string_split_at_first parta partb input separator)
  string(FIND "${input}" "${separator}" idx )
  if(${idx} LESS 0)
    set(${parta} "${input}" PARENT_SCOPE)
    set(${partb} "" PARENT_SCOPE)
    return()
  endif()

  string(SUBSTRING "${input}" 0 ${idx} pa)
  math(EXPR idx "${idx} + 1")

  string(SUBSTRING "${input}" ${idx} -1 pb)
  set(${parta} ${pa} PARENT_SCOPE)
  set(${partb} ${pb} PARENT_SCOPE)
endfunction()





# matches the first occurens of regex and returns it
function(regex_search str regex)
  string(REGEX MATCH "${regex}" res "${str}")  
  return_ref(res)
endfunction()




  #splits the specified string into lines
  ## normally the string would have to be semicolon encoded
  ## to correctly display lines with semicolons 
  function(string_lines input)      
    string_split("${input}" "\n" ";" )
    #string(REPLACE "\n" ";" input "${input}")
    return_ans(lines)
  endfunction()





  #splits string at last occurence of separator and retruns both parts
  function(string_split_at_last parta partb input separator)
    string(FIND "${input}" "${separator}" idx  REVERSE)
    if(${idx} LESS 0)
      set(${parta} "${input}" PARENT_SCOPE)
      set(${partb} "" PARENT_SCOPE)
      return()
    endif()

    string(SUBSTRING "${input}" 0 ${idx} pa)
    math(EXPR idx "${idx} + 1")

    string(SUBSTRING "${input}" ${idx} -1 pb)
    set(${parta} ${pa} PARENT_SCOPE)
    set(${partb} ${pb} PARENT_SCOPE)
  endfunction()




#decodes parentheses in a string
function(string_parentheses_encode str)
  string(REPLACE "†" "\(" str "${str}")
  string(REPLACE "‡" "\)" str "${str}")
  return_ref(str)
endfunction()






## string_take_address
##
## takes an address from the string ref  
function(string_take_address str_ref)
  string_take_regex("${str_ref}" ":[1-9][0-9]*")
  ans(res)
  set(${str_ref} ${${str_ref}} PARENT_SCOPE)   
  return_ref(res)
endfunction()





# remove match from in out var ${${str_name}}
# returns match
function(string_take str_name match)
  string(FIND "${${str_name}}" "${match}" index)
  #message("trying to tak ${match}")
  if(NOT ${index} EQUAL 0)
    return()
  endif()
  #message("took ${match}")
  string(LENGTH "${match}" len)
  string(SUBSTRING "${${str_name}}" ${len} -1 rest )
  set("${str_name}" "${rest}" PARENT_SCOPE)


  return_ref(match)
 
endfunction()




# tries to match the regex at the begging of ${${str_name}} and returns the match
# ${str_name} is shortened in the process
# match is returned
function(string_take_regex str_name regex)
  string(REGEX MATCH "^(${regex})" match "${${str_name}}")
  string(LENGTH "${match}" len)
  if(len)
    string(SUBSTRING "${${str_name}}" ${len} -1 res )
    set(${str_name} "${res}" PARENT_SCOPE)
    return_ref(match)
  endif()
  return()
endfunction()


function(string_take_regex_replace str_name regex replace)
  string_take_regex(${str_name} "${regex}")
  ans(match)
  if("${match}_" STREQUAL _)
    return()
  endif()
  set(${str_name} "${${str_name}}" PARENT_SCOPE)
  string(REGEX REPLACE "${regex}" "${replace}" match "${match}")
  return_ref(match)
endfunction()




# extracts a portion of the string negative indices translatte to count fromt back
function(string_slice str start_index end_index)
  # indices equal => select nothing

  string_normalize_index("${str}" ${start_index})
  ans(start_index)
  string_normalize_index("${str}" ${end_index})
  ans(end_index)

  if(${start_index} LESS 0)
    message(FATAL_ERROR "string_slice: invalid start_index ")
  endif()
  if(${end_index} LESS 0)
    message(FATAL_ERROR "string_slice: invalid end_index")
  endif()
  # copy array
  set(result)
  math(EXPR len "${end_index} - ${start_index}")
  string(SUBSTRING "${str}" ${start_index} ${len} result)

  return_ref(result)
endfunction()
  




# encodes semicolons with seldomly used utf8 chars.
# causes error for string(SUBSTRING) command
  function(string_semicolon_encode str)
    # make faster by checking if semicolon exists?
    string(ASCII  31 us)
    # string(FIND "${us}" has_semicolon)
    #if(has_semicolon GREATER -1) replace ...

    string(REPLACE ";" "${us}" str "${str}" )
    return_ref(str)
  endfunction()




# removes the back of a string
function(string_remove_ending original ending)
  string(LENGTH "${ending}" len)
  string(LENGTH "${original}" orig_len)
  math(EXPR len "${orig_len} - ${len}")
  string(SUBSTRING "${original}" 0 ${len} original)
  return_ref(original)
  endfunction()





## returns true if the given string is empty
## normally because cmake evals false, no,  
## which destroys tests for real emtpiness
##
##
 function(string_isempty  str)    
    if( "_" STREQUAL "_${str}" )
      return(true)
    endif()
    return(false)
 endfunction()




# returns true if ${str} contains ${search}
function(string_contains str search)
  string(FIND "${str}" "${search}" index)
  if("${index}" LESS 0)
    return(false)
  endif()
  return(true)
endfunction()




# replaces all non alphanumerical characters in a string with an underscore
function(string_normalize input)
	string(REGEX REPLACE "[^a-zA-Z0-9_]" "_" res "${input}")
	return_ref(res)
endfunction()




# decodes an encoded list
  function(string_decode_list str)
    string_semicolon_decode("${str}")
    ans(str)
    string_decode_bracket("${str}")
    ans(str)
    string_decode_empty("${str}")
    ans(str)
   # message("decoded3: ${str}")
    return_ref(str)
  endfunction()




# encodes parentheses in a string
  function(string_parentheses_encode str)
    string(REPLACE "\(" "†" str "${str}")
    string(REPLACE "\)" "‡" str "${str}")
  endfunction()




# returns the the parts of the string that overlap
# e.g. string_overlap(abcde abasd) returns ab
function(string_overlap lhs rhs)
  string(LENGTH "${lhs}" lhs_length)
  string(LENGTH "${rhs}" rhs_length)

  math_min("${lhs_length}" "${rhs_length}")
  ans(len)



  math(EXPR last "${len}-1")

  set(result)

  foreach(i RANGE 0 ${last})
    string_char_at(${i} "${lhs}")
    ans(l)
    string_char_at(${i} "${rhs}")
    ans(r)
    if("${l}" STREQUAL "${r}")
      set(result "${result}${l}")
    else()
      break()
    endif()
  endforeach()
  return_ref(result)

endfunction()





# returns true if str starts with search
function(string_starts_with str search)
  string(FIND "${str}" "${search}" out)
  if("${out}" EQUAL 0)
    return(true)
  endif()
  return(false)
endfunction()




## evaluates the string <str> in the current scope
## this is done by macro variable expansion
## evaluates both ${} and @@ style variables
macro(string_eval str)
  set_ans("${str}")
endmacro()





## shortens the string to be at most max_length long
  function(string_shorten str max_length)
    set(shortener "${ARGN}")
    if(shortener STREQUAL "")
      set(shortener "...")
    endif()

    string(LENGTH "${str}" str_len)
    string(LENGTH shortener shortener_len)
    math(EXPR combined_len "${str_len} + ${shortener_len}")

    if(NOT str_len GREATER "${max_length}")
      return_ref(str)
    endif()

    math(EXPR max_length "${max_length} - ${shortener_len}")

    string_slice("${str}" 0 ${max_length})
    ans(res)
    set(res "${res}${shortener}")
    return_ref(res)
  endfunction()






# returns true iff str ends with search
function(string_ends_with str search)
  string(FIND "${str}" "${search}" out REVERSE)
  if(${out} EQUAL -1)
  return(false)
  endif()
  string(LENGTH "${str}" len)
  string(LENGTH "${search}" len2)
  math(EXPR out "${out}+${len2}")
  if("${out}" EQUAL "${len}")
    return(true)
  endif()
  return(false)
endfunction()




# splits a string into parts with nested structures
# ie ( () () (( ) ())) ()  ( ())  is split into its main groups '( () () (( ) ()))','()','( ())'
  function(string_nested_split code open close)
    string(LENGTH "${code}" len)
    math(EXPR len "${len} -1")
    set(openings 0)
    set(last_index 0)
    set(result)
    foreach(i RANGE 0 ${len})
      string_char_at( "${i}" "${code}")
      ans(c)
      #message("char ${i}: ${c}")
      if("${c}_" STREQUAL "${open}_")
        if("${openings}" EQUAL 0)
          math(EXPR start "${last_index}")
          math(EXPR end "${i}")
          string_slice("${code}" "${start}" "${end}")
          ans(part)
       #   message("part ${part} ${start} ${end}")
          list(APPEND result "${part}")
          math(EXPR last_index "${i}+1")
        endif()
        math(EXPR openings "${openings} + 1")
      elseif("${c}_" STREQUAL "${close}_")
        math(EXPR openings "${openings} -1")
        if("${openings}" EQUAL 0)
          math(EXPR start "${last_index}")
          math(EXPR end "${i}")
          string_slice("${code}" "${start}" "${end}")
          ans(part)
        #  message("part ${part} ${start} ${end}")
          list(APPEND result "${open}${part}${close}")
          math(EXPR last_index "${i}+1")
        endif()
      endif()
    #  message("openings ${openings}")

    endforeach()
    string_slice("${code}" "${last_index}" -1)
    ans(last_part)
    string_isempty("${last_part}")
    ans(isempty)
    if(NOT isempty)
      list(APPEND result "${last_part}")
    endif()
    #message("asd ${result}")
    return_ref(result)

  endfunction()




  function(string_split_parts str length)
    ref_new()
    ans(first_node)
    
    set(current_node ${first_node})
    while(true)      
      string(LENGTH "${str}" len)       
      if(${len} LESS ${length})
        ref_set(${current_node} "${str}")
        set(str)
      else()
        string(SUBSTRING "${str}" 0 "${length}" part)
        string(SUBSTRING "${str}" "${length}" -1 str)
        ref_set(${current_node} "${part}")
      endif()
      if(str)
        ref_new()
        ans(new_node)
        map_set_hidden(${current_node} next ${new_node})
        set(current_node ${new_node})
      else()
        return_ref(first_node)
      endif()     
      
    endwhile()

  endfunction()




# wraps the substring command
# optional parameter end 
function(string_substring str start)
  set(len ${ARGN})
  if(NOT len)
    set(len -1)
  endif() 
  string_normalize_index("${str}" "${start}")
  ans(start)

  string(SUBSTRING "${str}" "${start}" "${len}" res)
  return_ref(res)
endfunction()




## takes a string which is delimited by any of the specified
## delimiters 
## string_take_any_delimited(<string&> <delimiters:<delimiter...>>)
  function(string_take_any_delimited str_ref)
    foreach(delimiter ${ARGN})
      string(LENGTH "${${str_ref}}" l1)
      string_take_delimited(${str_ref} "${delimiter}")
      ans(match)
      string(LENGTH "${${str_ref}}" l2)
      if(NOT "${l1}" EQUAL "${l2}")
        set("${str_ref}" "${${str_ref}}" PARENT_SCOPE)
        return_ref(match)
      endif()

    endforeach()
    return()
  endfunction()







function(string_take_whitespace __string_take_whitespace_string_ref)
  string_take_regex("${__string_take_whitespace_string_ref}" "[ ]+")
  ans(__string_take_whitespace_res)
  set("${__string_take_whitespace_string_ref}" "${${__string_take_whitespace_string_ref}}" PARENT_SCOPE)
  return_ref(__string_take_whitespace_res)
endfunction()





# decodes semicolons in a string
  function(string_semicolon_decode str)
    string(ASCII  31 us)
    string(REPLACE "${us}" ";" str "${str}")
    return_ref(str)
  endfunction()





# encodes brackets
function(string_encode_bracket str)
    string(ASCII 29 bracket_open)
    string(ASCII 28 bracket_close)
      string(REPLACE "[" "${bracket_open}" str "${str}") 
      string(REPLACE "]" "${bracket_close}" str "${str}")
      return_ref(str)
  endfunction()





#pads the specified string to be as long as specified
# if the string is longer then nothing is padded
# if no delimiter is specified than " " (space) is used
# if --prepend is specified the padding is inserted into front of string
function (string_pad str len)  
  set(delimiter ${ARGN})
#  message("delim ${delimiter}")
  list_extract_flag(delimiter --prepend)
  ans(prepend)
  if("${delimiter}_" STREQUAL "_")
    set(delimiter " ")
  endif()  
  string(LENGTH "${str}" actual)  
  if(${actual} LESS ${len})
    math(EXPR n "${len} - ${actual}")    
    string_repeat("${delimiter}" ${n})
    ans(padding)
    if(prepend)
      set(str "${padding}${str}")
    else()
      set(str "${str}${pad}")    
    endif()    
  endif()

  return_ref(str)
endfunction()




## tries to parse a delimited string
## returns either the original or the parsed delimited string
## delimiters can be specified via varargs
## see also string_take_delimited
function(string_decode_delimited str)
  string_take_delimited(str ${ARGN})
  ans(res)
  if("${res}_" STREQUAL "_")
    return_ref(str)
  endif()
  return_ref(res)
endfunction()




#replaces all occurrences of pattern with replace in str and returns str
function(string_replace str pattern replace)
  string(REPLACE "${pattern}" "${replace}" res "${str}")
  return_ref(res)
endfunction()




## combines the varargs into a string joining them with separator
## e.g. string_combine(, a b c) => "a,b,c"
function(string_combine separator )
  set(first true)
  set(res)
  foreach(arg ${ARGN})
    if(first )
      set(first false)
    else()
      set(res "${res}${separator}")
    endif()
    set(res "${res}${arg}")
  endforeach()
  return_ref(res)
endfunction()





# evaluates the string against the regex
# and returns true iff it matches
function(string_match  str regex)
  if("${str}" MATCHES "${regex}")
    return(true)
  endif()
  return(false)
endfunction()




  # repeats ${what} and separates it by separator
  function(string_repeat what n)
    set(separator "${ARGN}")
    set(res)
    if("${n}" LESS 1)
      return()
    endif()
    foreach(i RANGE 1 ${n})
      if(NOT ${i} EQUAL 1)
        set(res "${separator}${res}")
      endif()
      set(res "${res}${what}")
    endforeach()
    return_ref(res)
  endfunction()







# returns the first match in parent dir or parent dirs of path
function(file_find_up path n target)

  path("${path}")
  ans(path)


  # /tld is appended because only its parent dirs are gotten 
  path_parent_dirs("${path}/tld" ${n})
  ans(parent_dirs)

  foreach(parent_dir ${parent_dirs})
    if(IS_DIRECTORY "${parent_dir}/${target}")
      return("${parent_dir}/${target}")
    endif()
  endforeach()
  return()

endfunction()









function(paths_relative path_base)
  set(res)
  foreach(path ${ARGN})
    path_relative("${path_base}" "${path}")
    ans(c)
    list(APPEND res "${c}")
  endforeach()
  return_ref(res)
endfunction()






## returns a map of known mime types
function(mime_type_map)
  map_new()
  ans(mime_type_map)
  map_set(global mime_types "${mime_type_map}")

  function(mime_type_map)
    map_tryget(global mime_types)
    return_ans()
  endfunction()

  mime_types_register_default()



  mime_type_map()
  return_ans()
endfunction()






## returns the mimetyoe object for the specified name or extension
function(mime_type_get name_or_ext)
  mime_type_map()
  ans(mm)
  map_tryget("${mm}" "${name_or_ext}")
  return_ans()
endfunction()






function(mime_type_get_extension mime_type)
    mime_type_get("${mime_type}")
    ans(mt)
    map_tryget("${mt}" extensions)
    ans(extensions)
    list_pop_front(extensions)
    ans(res)
    return_ref(res)

return()
  if(mime_type STREQUAL "application/cmake")
    return("cmake")
  elseif(mime_type STREQUAL "application/json")
    return("json")
  elseif(mime_type STREQUAL "application/x-quickmap")
    return("qm")
  elseif(mime_type STREQUAL "application/x-gzip")
    return("tgz")
  elseif(mime_type STREQUAL "text/plain")
    return("txt")
  endif()

  return()
endfunction()





# writes the path the map creating submaps for every directory

function(path_to_map map path)
  
  path_split("${path}")
  ans(path_parts)

  set(current ${map})
  while(true)
    list_pop_front(path_parts)
    ans(current_part)


    
    map_tryget(${current} "${current_part}")
    ans(current_map)

    if(NOT path_parts)
      if(NOT current_map)
      map_set(${current} "${current_part}" "${path}")
      endif()
      return()
    endif()

    map_isvalid("${current_map}")
    ans(ismap)

    if(NOT ismap)
      map_new()
      ans(current_map)
    endif()

    map_set(${current} "${current_part}" ${current_map})
    set(current ${current_map})
  endwhile()
endfunction()




## returns true if file eists and is a supported archive
function(archive_isvalid file)
  mime_type("${file}")
  ans(types)


  list_contains(types "application/x-gzip")
  ans(is_archive)


  return_ref(is_archive)
endfunction()





  # configures a file and path
  function(file_configure_write base_dir file_name content)
    if(EXISTS "${content}")
      set(source_file "${content}")
      set(temp_file false)
    else()
      file_make_temporary( "${content}")
      ans(source_file)
      set(temp_file true)
    endif()

    # configure relative file path
    map_format("${file_name}")
    ans(configured_path)

    # if file exists configure it
    if(EXISTS "${source_file}" AND NOT IS_DIRECTORY "${source_file}")
      file_configure("${source_file}" "${base_dir}/${configured_path}" "@-syntax")
    endif()

    # remove temporary file
    if(temp_file)
    #  file(REMOVE "${source_file}")
    endif()
    return("${base_dir}/${configured_path}")
  endfunction()


  




# creates a temporary directory and returns its path
function(file_tempdir )
	oocmake_config(temp_dir)
	ans(temp_dir)
	#string(MAKE_C_IDENTIFIER id "${ARGN}")
	string_normalize( "${ARGN}")
	ans(id)
	set(tempdir "${temp_dir}/file_tempdir/${id}")
	set(i 0)
	while(true)
		if(NOT EXISTS "${tempdir}_${i}")
			set(tmp_dir "${tempdir}_${i}" PARENT_SCOPE)

			file(MAKE_DIRECTORY "${tempdir}_${i}")
			return("${tempdir}_${i}")
		endif()
		math(EXPR i "${i} + 1")
	endwhile()
endfunction()




# applies the glob expressions (passed as varargs)
# to the first n parent directories starting with the specified path
# order of result is in deepest path first
# 0 searches parent paths up to root
# @todo extend to quit search when first result is found
function(file_glob_up path n)
  path("${path}")
  ans(path)
  set(globs ${ARGN})

  # /tld is appended because only its parent dirs are gotten 
  path_parent_dirs("${path}/tld" ${n})
  ans(parent_dirs)

  set(all_matches )
  foreach(parent_dir ${parent_dirs})
    file_glob("${parent_dir}" ${globs})
    ans(matches)
    list(APPEND all_matches ${matches})
  endforeach()
  return_ref(all_matches)
endfunction()







# adds additional syntax to glob allowing exclusion by prepending a ! exclamation mark.
# e.g.
# file_extended_glob("dir" "**.cpp" "!build/**") 
# returns all cpp files in dir except if they are in the dir/build directory
function(file_extended_glob base_dir)
	set(args ${ARGN})
	list_extract_flag(args --relative)
	ans(relative)
	if(relative)
		set(relative --relative)
	endif()
	set(includes)
	set(excludes)
	foreach(current ${args})
		if("${current}" MATCHES "!.*")
			string(SUBSTRING "${current}" "1" "-1" current)
			list(APPEND excludes "${current}")
		else()
			list(APPEND includes "${current}")
		endif()
	endforeach()

	file_glob("${base_dir}" ${includes} ${relative})
	ans(includes)

	file_glob("${base_dir}" ${excludes} ${relative})
	ans(excludes)


	if(includes AND excludes)
		list(REMOVE_ITEM includes ${excludes})
	endif()

	return_ref(includes)
endfunction()




## returns true if the specified file is a tar archive 
function(file_istarfile file)
	path_qualify(file)
	if(NOT EXISTS "${file}")
		return(false)
	endif()
	if(IS_DIRECTORY "${file}")
		return(false)
	endif()
	tar(ztvf "${file}" --return-code)
	ans(res)
	if(NOT res EQUAL 0)
		return(false)
	endif()

	return(true)
	
endfunction()










# converts the varargs list of pahts to a map
function(paths_to_map )
  map_new()
  ans(map)
  foreach(path ${ARGN})
    path_to_map("${map}" "${path}")
  endforeach()
  return_ref(map)
endfunction()






function(file_find_up_parent path n target)
  file_find_up("${path}" "${n}" "${target}")
  ans(res)
  if(NOT res)
    return()
  endif()
  path_component("${res}" --parent-dir)
  return_ans()
endfunction()






## https://www.ietf.org/rfc/rfc2045.txt
function(mime_type_register mime_type)
  data("${mime_type}")
  ans(mime_type)

  map_tryget("${mime_type}" name)
  ans(name)
  if(name STREQUAL "")
    return()
  endif()

  mime_type_map()
  ans(mime_types)

  map_tryget("${mime_types}" "${name}")
  ans(existing_mime_type)
  if(existing_mime_type)
    message(FATAL_ERROR "mime_type ${name} already exists")
  endif()

  map_tryget("${mime_type}" extensions)
  ans(extensions)


  foreach(key ${name} ${extensions})
    map_append(${mime_types} "${key}" "${mime_type}")
  endforeach()

  return_ref(mime_type)

endfunction()







  # combines all dirs to a single path  
  function(path_combine )
    set(args ${ARGN})
    list_to_string(args "/")
    ans(path)
    return_ref(path)
  endfunction()




## mime_type_from_extension()->
##
## returns the mime type or types matching the specified file extension
##
function(mime_type_from_extension extension)

  if("${extension}" MATCHES "\\.(.*)")
    set(extension "${CMAKE_MATCH_1}")
  endif()

  string(TOLOWER "${extension}" extension)

  mime_type_map()
  ans(mime_types)

  map_tryget("${mime_types}" "${extension}")
  ans(mime_types)

  set(mime_type_names)
  foreach(mime_type ${mime_types})
    map_tryget("${mime_type}" name)
    ans(mime_type_name)
    list(APPEND mime_type_names "${mime_type_name}")  
  endforeach()

  return_ref(mime_type_names)
endfunction()






## mime_type_from_filename() -> 
##
## returns the mimetype for the specified filename
##
##
function(mime_type_from_filename file)
  get_filename_component(extension "${file}" EXT)
  mime_type_from_extension("${extension}")
  return_ans()
endfunction()




## returns true iff specified path does not contain any files
function(dir_isempty path)
  ls("${path}")
  ans(files)
  list(LENGTH files len)
  if(len)
    return(false)
  endif()
  return(true)
endfunction()




## uncompresses the file specified into the current pwd()
function(uncompress file)
  mime_type("${file}")
  ans(types)

  if("${types}" MATCHES "application/x-gzip")
    directory_ensure_exists(".")  
    path_qualify(file)
    tar(xzf "${file}" ${ARGN})
    return_ans()
  else()
    message(FATAL_ERROR "unsupported compression: '${types}'")
  endif()
endfunction()










# returns the path specified by path_rel relative to 
  # path_base using parent dir path syntax (../../path/to/x)
  # if necessary
  # e.g. path_rel(c:/dir1/dir2 c:/dir1/dir3/dir4)
  # will result in ../dir3/dir4
  # returns nothing if transformation is not possible
  function(path_relative path_base path_rel)
    set(args ${ARGN})

    path("${path_base}")
    ans(path_base)
    path("${path_rel}")
    ans(path_rel)


    if("${path_base}" STREQUAL "${path_rel}")
      return(".")
    endif()

    path_split("${path_base}")
    ans(base_parts)

    path_split("${path_rel}")
    ans(rel_parts)

    set(result_base)

    set(first true)

    while(true)
      list_peek_front(base_parts)
      ans(current_base)
      list_peek_front(rel_parts)
      ans(current_rel)


      if(NOT "${current_base}" STREQUAL "${current_rel}")
        if(first)
          return_ref(path_rel)
        endif()
        break()
      endif()
      set(first false)

      path_combine("${result_base}" "${current_base}")
      ans(result_base)
      list_pop_front(base_parts)
      list_pop_front(rel_parts)
    endwhile()


    set(result_path)

    foreach(base_part ${base_parts})
      path_combine(${result_path} "..")
      ans(result_path)
    endforeach()


    path_combine(${result_path} ${rel_parts})
    ans(result_path)



    if("${result_path}" MATCHES "^\\/")
      string_substring("${result_path}" 1)
      ans(result_path)
    endif()

    return_ref(result_path)
  endfunction()
# transforms a path to a path relative to base_dir
#function(path_relative base_dir path)
#  path("${base_dir}")
#  ans(base_dir)
#  path("${path}")
#  ans(path)
#  string_take(path "${base_dir}")
#  ans(match)
#
#  if(NOT match)
#    return_ref(path)
#    #message(FATAL_ERROR "${path} is  not relative to ${base_dir}")
#  endif()
#
#  if("${path}" MATCHES "^\\/")
#    string_substring("${path}" 1)
#    ans(path)
#  endif()
#
#
#  if(match AND NOT path)
#    set(path ".")
#  endif()
#
#  return_ref(path)
#endfunction()
#




# creates random none existing file using a pattern
# the first file which does not exist is returned
function(file_random  in_pattern)
  while(true)
    make_guid(id)
	  string(REPLACE "{{id}}" ${id} in_pattern ${in_pattern})
    set(current_name "${in_pattern}")
    if(NOT EXISTS ${current_name})
      return_ref(current_name)
    endif()
  endwhile()
endfunction()





  function(file_configure source_file target_file syntax)
    if("${syntax}" STREQUAL "@-syntax")
      configure_file("${source_file}" "${target_file}" @ONLY)
      return()
    endif()
    message(FATAL_ERROR "file_configure currently only implemented @-syntax")
  endfunction()




# returns the specified max n (all if n = 0)
# parent directories of path
function(path_parent_dirs path)
  set(continue 99999)
  if(ARGN )
    set(continue "${ARGN}")

    if("${continue}" EQUAL 0)
      set(continue 99999)
    endif()
  endif()

  path("${path}")
  ans(path)

  set(isrooted false)
  if("_${path}" MATCHES "^_[/]")
    set(isrooted true)
  endif()

  path_split("${path}")
  ans(parts)


  set(parent_dirs)
  while(true)
    if(NOT parts OR ${continue} LESS 1)
      break()
    endif()
    list_pop_back(parts)
    path_combine(${parts})
    ans(current)      

    if(isrooted)
      set(current "/${current}")
    endif()
    
    if("_${current}" STREQUAL "_")
      break()
    endif()
    list(APPEND parent_dirs "${current}")
    math(EXPR continue "${continue} - 1")

  endwhile()
  return_ref(parent_dirs)
endfunction()







  # writes the specified content to the specified path
  function(file_write path content)
    path("${path}")
    ans(path)
    if(IS_DIRECTORY "${path}")
      message(WARNING "trying to write to path '${path}' which is a directory")
      return(false)
    endif()
    file(WRITE "${path}" "${content}")
    return(true)
  endfunction()




  ## compares the specified files
  ## returning true if their content is the same else false
  function(file_equals lhs rhs)
    path("${lhs}")
    ans(lhs)

    path("${rhs}")
    ans(rhs)

    cmake(-E compare_files "${lhs}" "${rhs}" --return-code)
    ans(return_code)
    
    if("${return_code}" STREQUAL "0")
      return(true)
    else()
      return(false)
    endif()

  endfunction()






  function(file_issubdirectoryof  subdir path)
    get_filename_component(path "${path}" REALPATH)
    get_filename_component(subdir "${subdir}" REALPATH)
    string_starts_with("${subdir}" "${path}")
    return_ans()
  endfunction()




# makes all paths passed as varargs into paths relative to base_dir
function(paths_make_relative base_dir)
  set(res)
  get_filename_component(base_dir "${base_dir}" REALPATH)

  foreach(path ${ARGN})
    get_filename_component(path "${path}" REALPATH)
    file(RELATIVE_PATH path "${base_dir}" "${path}")
    list(APPEND res "${path}")
  endforeach()

  return_ref(res)
endfunction()





# tar command 
# use cvzf to compress files relative to pwd() to a tgz file 
# use xzf to uncompress a tgz file to the pwd()
function(tar)
  cmake(-E tar ${ARGN})
  return_ans()
endfunction()




function(file_find file include_dirs extensions)
    #message("trying to find ${file} in ${include_dirs}")
    set(extensions "false;${extensions}")
    set(include_dirs "false;${include_dirs}")
    foreach(dir ${include_dirs})
      if(dir AND NOT "${dir}"  MATCHES ".*/$")
        set(dir "${dir}/")
      elseif(NOT dir)
        set(dir "")
      endif()

      foreach(extension ${extensions})
        if(extension AND NOT "${extension}" MATCHES "^\\..*" )
          set(extension ".${extension}")
        elseif(NOT extension)
          set(extension "")
        endif()
        set(test_path "${dir}${file}${extension}")
        #message("test_path ${test_path}")
        string(STRIP "${test_path}" test_path)
        if(EXISTS "${test_path}" )
          get_filename_component(file "${test_path}" REALPATH)
          #message("returning ${file}")
          return_ref(file)
        endif()
      endforeach()
    endforeach()
    return()
  endfunction()




# creates a temporary file
function(file_make_temporary content)
  oocmake_config(temp_dir)
  ans(temp_dir)
	file_random( "${temp_dir}/file_make_temporary_{{id}}.tmp")
  ans(rnd)
	file(WRITE ${rnd} "${content}")
  return_ref(rnd)
endfunction()








function(compress_tgz target_file)
  # target_file file
  path_qualify(target_file)

  # get current working dir
  pwd()
  ans(pwd)

  # get all files to compress
  file_glob("${pwd}" ${args} --relative)
  ans(paths)

  # compress all files into target_file using paths relative to pwd()
  tar(cvzf "${target_file}" ${paths})
  return_ans()
endfunction()




## tries to read the spcified file format
function(fread_data path)
  set(args ${ARGN})


  path_qualify(path)
  
  list_pop_front(args)
  ans(mime_type)

  if(NOT mime_type)

    mime_type("${path}")
    ans(mime_type)

    if(NOT mime_type)
      return()
    endif()

  endif()


  if("${mime_type}" MATCHES "application/json")
    json_read("${path}")
    return_ans()
  elseif("${mime_type}" MATCHES "application/x-quickmap")
    qm_read("${path}")
    return_ans()
  else()
    return()
  endif()

endfunction()






function(mime_types_register_default)
  mime_type_register("{
      name:'application/x-gzip',
      description:'',
      extensions:['tgz','gz','tar.gz']
  }")
  mime_type_register("{
      name:'application/zip',
      description:'',
      extensions:['zip']
  }")


  mime_type_register("{
      name:'application/x-7z-compressed',
      description:'',
      extensions:['7z']
  }")

  mime_type_register("{
      name:'text/plain',
      description:'',
      extensions:['txt','asc']
  }")


  mime_type_register("{
      name:'application/x-quickmap',
      description:'CMake Quickmap Object Notation',
      extensions:['qm']
  }")



  mime_type_register("{
      name:'application/json',
      description:'JavaScript Object Notation',
      extensions:['json']
  }")



  mime_type_register("{
      name:'application/x-cmake',
      description:'CMake Script File',
      extensions:['cmake']
  }")



  mime_type_register("{
      name:'application/xml',
      description:'eXtensible Markup Language',
      extensions:['xml']
  }")


endfunction()




## returns the file type for the specified file
## only existing files can have a file type
## if an existing file does not have a specialized file type
## the extension is returned
function(mime_type file)
  path_qualify(file)
  if(NOT EXISTS "${file}")
    return(false)
  endif()

  if(IS_DIRECTORY "${file}")
    return(false)
  endif()


  mime_type_from_file_content("${file}")
  ans(mime_type)

  if(mime_type)
    return_ref(mime_type)
  endif()

  mime_type_from_filename("${file}")

  return_ans()
endfunction()


function(mime_type_from_file_content file)
  path_qualify(file)
  if(NOT EXISTS "${file}")

  endif()

  file_istarfile("${file}")
  ans(is_tar)
  if(is_tar)
    return("application/x-gzip")
  endif()


  file_isqmfile("${file}")
  ans(is_qm)
  if(is_qm)
    return("application/x-quickmap")
  endif()

  return()
endfunction()

function(file_isqmfile file)
    path_qualify(file)
    if(NOT EXISTS "${file}" OR IS_DIRECTORY "${file}")
      return(false)
    endif()
  file(READ "${file}" result LIMIT 3)
  if(result STREQUAL "#qm")
    return(true)
  endif()

  return(false)

endfunction()





  # splits the speicifed path into its directories and files
  # e.g. c:/dir1/dir2/file.ext -> ['c:','dir1','dir2','file.ext'] 
  function(path_split path)
    if("_${path}" MATCHES "^_[\\/]")
      string_substring("${path}" 1)
      ans(path)
    endif()
    string_split("${path}" "[/]")
    ans(parts)

    return_ref(parts)
  endfunction()




#uncompresses specific files from archive specified by varargs and stores them in target_dir directory
function(uncompress_file target_dir archive)
  set(files ${ARGN})

  path_qualify(archive)

  mime_type("${archive}")
  ans(types)


  if("${types}" MATCHES "application/x-gzip")
    pushd("${target_dir}" --create)
      tar(-zxvf "${archive}" ${files})
      ans(result)
    popd()
    return_ref(result)
  else()
    message(FATAL_ERROR "unsupported compression: '${types}'")
  endif()

endfunction()





# compresses all files specified in glob expressions (relative to pwd) into ${target_file} tgz file
# usage: compress(<file> [<glob> ...]) - 
# 
function(compress target_file)
  set(args ${ARGN})
  
  list_extract_labelled_value(args --format)
  ans(format)

  ## try to resolve format by extension
  if("${format}_" STREQUAL "_")
    mime_type_from_filename("${target_file}")
    ans(format)
  endif()

  ## set default formt to application/x-gzip
  if("${format}_" STREQUAL "_")
    set(format "application/x-gzip")
  endif()

  if(format STREQUAL "application/x-gzip")
    compress_tgz("${target_file}" ${args})
    return_ans()
  else()
    message(FATAL_ERROR "format not supported: ${format}, target_file: ${target_file}")
  endif()
endfunction()








# creates a temporary file with a specific extension
function(file_tmp extension content)
  oocmake_config(temp_dir)
  ans(temp_dir)
  file_random( "${temp_dir}/file_make_temporary_{{id}}.${extension}")
  ans(rnd)
  file(WRITE ${rnd} "${content}")
  return_ref(rnd)
endfunction()





# an extended glob function
# globs paths relative to base_dir
# glob expressions starting with / will be normally globbed
# expressions not starting with slash will be globbed recrusively
# specifiying the --relative flag will return paths relative to base_dir 
function(file_glob base_dir)
  set(args ${ARGN})
  list_extract_flag(args --relative)
  ans(relative)
  
  set(globs)
  set(globs_recurse)
  foreach(arg ${args})
    string_starts_with("${arg}" /)
    ans(notRecurse)
    if(notRecurse)
      string(SUBSTRING "${arg}" 1 -1 arg)
      list(APPEND globs ${arg})
    else()
      list(APPEND globs_recurse ${arg})
    endif()
  endforeach()
  set(slash /)

  list_combinations(base_dir slash globs)
  ans(globs)

  list_combinations(base_dir slash globs_recurse)
  ans(globs_recurse)


  set(glob_files)
  set(glob_recurse_files)
  if(globs)
    file(GLOB glob_files ${globs})
  endif()
  if(globs_recurse)
    file(GLOB_RECURSE glob_recurse_files ${globs_recurse})
  endif()

  set(files)

  foreach(file ${glob_files} ${glob_recurse_files})
    get_filename_component(file "${file}" REALPATH)
    if(relative)
      file(RELATIVE_PATH file ${base_dir} ${file})
      list(APPEND files "${file}")
    else()
      list(APPEND files "${file}")
    endif()
  endforeach()
  if(files)
    list(REMOVE_DUPLICATES files)
  endif()
 # foreach(file ${files})
 #   message("file ${file}")
 # endforeach()

  
  return_ref(files)
endfunction()






  # configures a map of files where the key is the configurable path and content
  # is either an existing file or  string cotnent for a file
  function(file_configure_write_map base_dir files)
    obj("${files}")
    ans(files)
    set(res)
    map_keys("${files}" )
    ans(file_names)
    foreach(file_name ${file_names})
      # get value for file. if value is a valid file use that file 
      # else use value as the content for the file
      map_get("${files}"  "${file_name}")
      ans(content)
      file_configure_write("${base_dir}" "${file_name}" "${content}")
      ans(configured_path)
      list(APPEND res "${configured_path}")
    endforeach()
    return(${res}) 
  endfunction()





  # finds the closest parent dir (or dir itself)
  # that contains any of the specified glob expressions
  # (also see file_glob for syntax)
  function(path_find_first_parent_dir_containing dir )
    file_glob_up("${dir}" 0 ${ARGN})
    ans(matches)
    list_peek_front(matches)
    ans(first_match)
    if(NOT first_match)
      return()
    endif()


    path_component("${first_match}" PATH)
    ans(first_match)

    return_ref(first_match)
  endfunction()




# adds an event handler to the event specified by name
function(event_addhandler name handler)
  event("${name}")
  ans(event)
  
  map_tryget("${event}" handlers)
  ans(handlers)

  set(handlers ${handlers} "${handler}")
  map_append("${event}" handlers "${handler}")
  list_unique(handlers)
  ans(handlers)
  map_set("${event}" handlers "${handlers}")

  return()
endfunction()




# returns the global events map
function(events)

  function(events)
    map_get(global events)
    ans(events)
    return_ref(events)
  endfunction()

  map_new()
  ans(events)
  map_set(global events ${events})
  events(${ARGN})
  return_ans()
endfunction()





# returns an exisitng event or a new event
function(event name)
  event_get("${name}")
  ans(event)
  if(NOT event)
    event_new("${name}")
    ans(event)
  endif()
  
  return_ref(event)
endfunction()




# returns the event identified by name
function(event_get name)
  events()
  ans(events)
  map_tryget(${events} "${name}")
  return_ans()
endfunction()





# emits the specified event 
# calls all registered event handlers for event '<name>'
function(event_emit event_name)
  event_get("${event_name}")
  ans(event)
  set(result)

  if(event)    
    set(previous_handlers)
    # loop solang as new event handlers are appearing
    while(true)
      map_tryget(${event} handlers)
      ans(handlers)
      list(REMOVE_ITEM handlers ${previous_handlers} "")
      list(APPEND previous_handlers ${handlers})

      list_length(handlers)
      ans(length)
      if(NOT "${length}" GREATER 0) 
        break()
      endif()

      foreach(handler ${handlers})
        rcall(success = "${handler}"(${ARGN}))
        list(APPEND result "${success}")
      endforeach()

    endwhile()
  endif()

  if(NOT "${event_name}" STREQUAL "on_event")
    event_emit(on_event "${event_name}" "${ARGN}")
    return_ans()
  endif()

  return_ref(result)
endfunction() 





# creates an registers a new event
function(event_new name)
  events()
  ans(events)

  map_new()
  ans(event)

  map_set(${event} name "${name}")
  map_set(${events} "${name}" ${event})
  
  return(${event})  
endfunction()




# removes the specified handler from the event idenfied by name
function(event_removehandler name handler)
  event_get("${name}")
  ans(event)
  if(NOT event)
    return(false)
  endif()
  map_tryget("${event}" handlers)
  ans(handlers)
  list_find(handlers "${handler}")
  ans(hasValue)
  if(hasValue LESS 0)
    return(false)
  endif()
  list_remove(handlers "${handler}")
  map_set("${event}" handlers "${handlers}")
  return(true)
endfunction()





function(config_function config_obj config_definition key)
    set(args ${ARGN})

  if("${key}"  STREQUAL "*")
    return(${config_obj})
  endif()
  if("${key}" STREQUAL "help")
    list_structure_print_help(${config_definition})
    return()
  endif()
  if("${key}" STREQUAL "print" )
    json_print(${config_obj})
    return()
  endif()
  if("${key}" STREQUAL "set")
    list_pop_front(args)
    ans(key)
    map_set("${config_obj}" "${key}" ${args})
  endif()
  map_get("${config_obj}" "${key}")
  return_ans()
endfunction()






function(config_setup name definition)
  map_get(global unused_command_line_args)
  ans(args)
  structured_list_parse("${definition}" ${args})
  ans(config)
  map_tryget(${config} unused)
  ans(args)
  map_set(global unused_command_line_args ${args})
  curry(config_function("${config}" "${definition}" /1) as "${name}")
endfunction()





macro(target_compile_options)
  _target_compile_options(${ARGN})
  event_emit(target_compile_options ${ARGN})

endmacro()





# returns all known target names
macro(target_list)
  map_tryget(global target_names)
endmacro()






function(target_append tgt_name key)
	set_property(
		TARGET "${tgt_name}"
		APPEND
		PROPERTY "${key}"
		${ARGN})
	return()
endfunction()





# prints the list of known targets 
function(print_targets)
  target_list()
  ans(res)
  foreach(target ${res})
    message("${target}")
  endforeach()

endfunction()


function(print_project_tree)
  map_tryget(global project_map)
  ans(pmap)

  json_print(${pmap})
  return()

endfunction()


function(print_target target_name)
  target_get_properties(${target_name})
  ans(res)
  json_print(${res})
endfunction()




# overwrites add_library
# same function as cmakes original add_library
# emits the event add_library with all parameters of the add_library call
# emits the event on_target_added library with all parameters of the call added
# registers the target globally so it can be iterated via 
macro(add_library)
  _add_library(${ARGN})
  event_emit(add_library ${ARGN})

  event_emit(on_target_added library ${ARGN})
  target_register(${ARGN})


  
endmacro()





macro(add_custom_target)
  _add_custom_target(${ARGN})


  event_emit(add_custom_target ${ARGN})
  event_emit(on_target_added custom ${ARGN})
  target_register(${ARGN})
endmacro()




# registers the target globally
# the name of the target is added to targets
#  or target_list()
function(target_register target_name)
  map_new()
  ans(target_map)
  map_set(global target_map ${target_map})
  function(target_register target_name)
    map_new()
    ans(tgt)
    map_set(${tgt} name "${target_name}")
    map_set(${tgt} project_name ${project_name})
    map_append(global targets ${tgt})
    map_append(global target_names ${target_name}) 
    map_get(global target_map)
    ans(target_map)
    map_set(${target_map} ${target_name} ${tgt}) 
    project_object()
    ans(proj)
    if(proj)
      map_append(${proj} targets ${tgt})
    endif()
    return_ref(tgt)
  endfunction()
  target_register(${target_name} ${ARGN})
  return_ans()
endfunction()









macro(target_compile_definitions)
  _target_compile_definitions(${ARGN})
  event_emit(target_compile_definitions ${ARGN})

endmacro()




# overwrites install command
#  emits event install and on_target_added(install ${ARGN)
# registers install target globally
macro(install)
  _install(${ARGN})
  event_emit(install ${ARGN})

  event_emit(on_target_added install install ${ARGN})
  target_register(install install ${ARGN})

endmacro()





macro(add_test)
  _add_test(${ARGN})
  event_emit(add_test ${ARGN})
  event_emit(on_target_added test ${ARGN})
  target_register(${ARGN})

endmacro()




# overwrites target_link_libraries
# emits the event target_link_libraries
macro(target_link_libraries)
  _target_link_libraries(${ARGN})
  target_link_libraries_register(${ARGN})
  event_emit(target_link_libraries ${ARGN})
  
endmacro()

function(target_link_libraries_register target)
  
endfunction()





macro(add_dependencies)
  _add_dependencies(${ARGN})
  event_emit(add_dependencies ${ARGN})

endmacro()







# overwrites project so that it can be registered
macro(project)
  set(parent_project_name "${PROJECT_NAME}")
  _project(${ARGN})
  set(project_name "${PROJECT_NAME}") 
  project_register(${ARGN})
  event_emit("project" ${ARGN})
endmacro()







function(target_set tgt_name key)
	set_property(
		TARGET "${tgt_name}"
		PROPERTY "${key}"
		${ARGN}
		)
	return()
endfunction()





function(target_append_string tgt_name key)
	set_property(
		TARGET "${tgt_name}"
		APPEND_STRING
		PROPERTY "${key}"
		${ARGN})
	return()
endfunction()







function(target_get tgt_name key)
	get_property(
		val
		TARGET "${tgt_name}"
		PROPERTY "${key}"
		)
	return_ref(val)
endfunction()





# 
function(project_register name)
  map_new()
  ans(pmap)
  map_set(global project_map ${pmap})
  function(project_register name)
    map_new()
    ans(cmake_current_project)
    map_set(${cmake_current_project} name "${name}")
    map_set(${cmake_current_project} directory "${CMAKE_CURRENT_LIST_DIR}")
    map_append(global projects ${cmake_current_project})
    map_append(global project_names ${name})
    map_tryget(global project_map)
    ans(pmap)
    map_set(${pmap} ${name} ${cmake_current_project})
  endfunction()
  project_register(${name} ${ARGN})
  return_ans()
endfunction()

# returns the project object identified by name
function(project_object)
  set(name ${ARGN})
  if(NOT name)
    # set to current project name
    set(name ${project_name})
    if(NOT name)
      set(name "${PROJECT_NAME}")
    endif()
  endif()
  
  map_tryget(global project_map)
  ans(res)
  if(NOT res)
    return()
  endif()
  map_tryget(${res} ${name})
  return_ans()
endfunction()

# returns the names of all project
macro(project_list)
  map_tryget(global project_names)
endmacro()




function(target_include_directories target)

if(NOT COMMAND _target_include_directories)
  cmake_parse_arguments("" "SYSTEM;BEFORE;PUBLIC;INTERFACE;PRIVATE" "" "" ${ARGN} )
  message(DEBUG "using fallback version of target_include_directories, consider upgrading to cmake >= 2.8.10")
  
  if(_SYSTEM OR _BEFORE OR _INTERFACE OR _PRIVATE)
    message(FATAL_ERROR "shim for target_include_directories does not support SYSTEM, PRIVATE, INTERFACE or BEFORE upgrade to cmake >= 2.8.10")
  endif()
    foreach(arg ${ARGN})
      if(TARGET "${arg}")
        get_property(includes TARGET ${arg} PROPERTY INCLUDE_DIRECTORIES)
        set_property(TARGET ${target} APPEND PROPERTY ${includes})
      else()
        message(FATAL_ERROR "shim version of target_include_directories only supports targets. upgrade cmake to >=2.8.10")
      endif()
    endforeach()
  return()
else()
  # default implementation
  _target_include_directories(${target} ${ARGN})
endif()
  event_emit(target_include_directories ${ARGN})
  
endfunction()





macro(add_executable)
  _add_executable(${ARGN})
  event_emit(add_executable ${ARGN})
  event_emit(on_target_added executable ${ARGN})
  target_register(${ARGN})
endmacro()




macro(include_directories)
  _include_directories(${ARGN})
  event_emit(include_directories "${ARGN}")
endmacro()





function(target_has tgt_name key)
	get_property(
		val
		TARGET "${tgt_name}"
		PROPERTY "${key}"
		SET)
	return_ref(val)
endfunction()






  function(indent_level)
    map_peek_back(global __indentlevelstack)
    ans(lvl)
    if(NOT lvl)
      return(0)
    endif()
    return_ref(lvl)
  endfunction()




function(test)



  indent_level_push(0)

  indent("asd" "...")
  ans(res)
  assert(${res} STREQUAL "asd")

  indent_level_push(+1)
  ans(storedlevel)
  indent("asd" "...")
  ans(res)
  assert(${res} STREQUAL "...asd")

  indent_level_push(+1)
  indent_level()
  ans(lvl)
  assert(${lvl} EQUAL 2)
  indent("asd" "...")
  ans(res)
  assert(${res} STREQUAL "......asd")


  indent_level_push()
  indent_level()
  ans(lvl)
  assert(${lvl} EQUAL 3)


  indent_level_restore(${storedlevel})
  indent_level()
  ans(lvl)
  assert(${lvl} EQUAL 1)

  
  

  indent_level_pop()


endfunction()





  function(indent_level_pop)
    map_pop_back(global __indentlevelstack)
    indent_level_current()
    return_ans()
   endfunction()





  function(indent_level_restore)
    set(target ${ARGN})
    while(true)
      indent_level_current()
      ans(current_level)
      if("${target}" LESS "${current_level}")
        map_pop_back(global __indentlevelstack)
      else()
        break()
      endif()
    endwhile()
    return()
  endfunction()




## returns the current index level index which can be used to 
## restore the index level to a specific point
  function(indent_level_current)
    map_property_length(global __indentlevelstack)
    ans(idx)
    math(EXPR idx "${idx} -1")
    if("${idx}" LESS 0)
      set(idx 0)
    endif()
    return_ref(idx)
  endfunction()





  function(indent_get)
    list(LENGTH ARGN len)
    set(indent "  ")
    if(len)
      set(indent "${ARGN}")
    endif()
    indent_level()
    ans(lvl)
    string_repeat("${indent}" "${lvl}")
    return_ans()
  endfunction()






  function(indent str)
    indent_get(${ARGN})
    ans(indent)
    set(str "${indent}${str}")
    return_ref(str)
  endfunction()






  function(indent_level_push)
    set(new_lvl ${ARGN})
    if("${new_lvl}_" STREQUAL "_")
      set(new_lvl +1)
    endif()
    if("${new_lvl}" MATCHES "^[+\\-]")
      indent_level()
      ans(current_level)
      math(EXPR new_lvl "${current_level} ${new_lvl}")
    endif()
    map_push_back(global __indentlevelstack "${new_lvl}")
    indent_level_current()
    return_ans()
  endfunction()




function(map_query query)
	# get definitions
	string(STRIP "${query}" query)
	set(regex "(from .* in .*(,.* in .*)*)((where).*)")
	string(REGEX REPLACE "${regex}" "\\1" sources "${query}")

	# get query
	string(LENGTH "${sources}" len)
	string(SUBSTRING "${query}" ${len} -1 query)
	string(STRIP "${query}" query)


	# get query predicate and selection term
	string(REGEX REPLACE "where(.*)select(.*)" "\\1" where "${query}")
	string(REGEX REPLACE "where(.*)select(.*)" "\\2" select "${query}")
	string(STRIP "${where}" where)
	string(STRIP "${select}" select)
	string_split( "${where}" " ")
	ans(where_parts)

	#remove "from " from sources
	string(SUBSTRING "${sources}" 5 -1 sources)



	# callback function for map_foreach
	function(map_query_foreach_action)
		#print_locals()
		#message("${where_parts} = ${installed_pkg} + ${dependency_pkg}")
		map_format( "${where_parts}")
		ans(current_where)
		# return value
		if(${current_where})
			map_transform( "${select}")
			ans(selection)
			ref_append(${map_query_result} "${selection}")
		endif()

	endfunction()

	# create a ref where the result is stored
	ref_new()
	ans(map_query_result)
	map_foreach(map_query_foreach_action "${sources}")
	
	# get the result
	ref_get(${map_query_result} )
	ans(res)
	ref_delete(${map_query_result})

	return_ref(res)
	
endfunction()




# write the specified object reference to the specified file
## todo rename to fwrite_json(path data)
  function(json_write file obj)
    path("${file}")
    ans(file)
    json_indented(${obj})
    ans(data)
    file(WRITE "${file}" "${data}")
    return()
  endfunction()




function(json_print)
  json_indented(${ARGN})
  ans(res)
  _message("${res}")
endfunction()




function(json2 input)
  
  json2_definition()
  ans(lang)
  language_initialize(${lang})
  ref_set(json2_language_definition "${lang}")
  function(json2 input) 
    checksum_string("${input}")   
    ans(ck)
    file_cache_return_hit("${ck}")

    ref_get(json2_language_definition)
    ans(lang)

    map_new()
    ans(ctx)
    map_set(${ctx} input "${input}")
    map_set(${ctx} def "json")
    obj_setprototype(${ctx} "${lang}")

    #lang2(output json2 input "${input}" def "json")
    lang(output ${ctx})
    ans(res)
    file_cache_update("${ck}" ${res})
    return_ref(res)
  endfunction()
  json2("${input}")
  return_ans()
endfunction()




# orders the specified lst by applying the comparator
function(map_order _lst comparator)
	function_import("${comparator}" as map_sort_comparator REDEFINE)
	set(_i 0)
	set(_j 0)
	list(LENGTH ${_lst} _len)
	math(EXPR _len "${_len} -1")
	# slow sort
	while(true)
		if(NOT (${_i} LESS ${_len}))

			break()
		endif()
		list(GET ${_lst} ${_i} _a)
		list(GET ${_lst} ${_j} _b)
		map_sort_comparator(_res ${_a} ${_b})
		
		if(_res GREATER 0)
			list_swap(${_lst} ${_i} ${_j})
		endif()

		math(EXPR _j "${_j} + 1")
		if(${_j} GREATER ${_len})
			math(EXPR _i "${_i} + 1")
			math(EXPR _j "${_i} + 1")
		endif()

	endwhile()
	
	set(${_lst} ${${_lst}} PARENT_SCOPE)
endfunction()




function(map_graphsearch)
	set(options)
  	set(oneValueArgs SUCCESSORS VISIT PUSH POP)
  	set(multiValueArgs)
  	set(prefix)
  	cmake_parse_arguments("${prefix}" "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  	#_UNPARSED_ARGUMENTS
  	# setup functions

  	if(NOT _SUCCESSORS)		
		function(gs_successors result node)
			#ref_isvalid(${node})
			#ans(isref)
			map_isvalid( ${node} )
			ans(ismap)
			list_isvalid(${node}  )
			ans(islist)
			set(res)
			if(ismap)
				map_keys(${node} )
				ans(keys)
				map_values(${node}  ${keys})
				ans(res)
			elseif(islist)
				list_values(${node} )
				ans(values)
			endif()
			set(${result} "${res}" PARENT_SCOPE)
		endfunction()
	else()
		function_import("${_SUCCESSORS}" as gs_successors REDEFINE)
	endif()
	
	if(NOT _VISIT)
		function(gs_visit cancel value)
		endfunction()
	else()
		function_import("${_VISIT}" as gs_visit REDEFINE)
	endif()

	if(NOT _POP)
		function(gs_pop result)
			set(node)
			stack_peek(__gs)
			ans(node)
			if(NOT node)
				set(${result} PARENT_SCOPE)
				return()
			endif()
			stack_pop(__gs )
			ans(node)
			set(${result} "${node}" PARENT_SCOPE)
		endfunction()
	else()
		function_import("${_POP}" as gs_pop REDEFINE)
	endif()

	if(NOT _PUSH)
		function(gs_push node)
			stack_push(__gs ${node})
		endfunction()
	else()
		function_import("${_PUSH}" as gs_push REDEFINE)
	endif()

	# start of algorithm

	# add initial nodes to container
	foreach(node ${_UNPARSED_ARGUMENTS})
		gs_push(${node})
	endforeach()

	# iterate as long as there are nodes to visit
	while(true)
		set(current)
		# get first node
		gs_pop(current)
		if(NOT current)
			break()
		endif()

		set(cancel false)
		# visit node 
		# if cancel is set to true do not add successors
		gs_visit(cancel ${current})
		if(NOT cancel)
			gs_successors(successors ${current})
			foreach(successor ${successors})
				gs_push(${successor})
			endforeach()
		endif()
	endwhile()
endfunction()




function(map_exists this )
	get_property(map_exists GLOBAL PROPERTY "${this}" SET)
  return(${map_exists})
endfunction()




# prints all values of the map
function(map_print this)
	map_keys(${this} )
  ans(keys)
	foreach(key ${keys})
		map_get(${this}   ${key})
    ans(value)
		message("${key}: ${value}")
	endforeach()
endfunction()




## initializes a new mapiterator
  function(map_iterator map)
    map_keys("${map}")
    ans(keys)
    set(iterator "${map}" before_start ${keys})
    return_ref(iterator)    
  endfunction()






# use this macro inside of a while(true) loop it breaks when the iterator is over
# e.g. this prints all key values in the map
# while(true) 
#   map_iterator_break(myiterator)
#   message("${myiterator.key} = ${myiterator.value}")
# endwhile()
macro(map_iterator_break it_ref)
  map_iterator_next(${it_ref})
  if("${it_ref}.end")
    break()
  endif()
endmacro()




## this function moves the map iterator to the next position
## and returns true if it was possible
## e.g.
## map_iterator_next(myiterator) 
## ans(ok) ## is true if iterator had a next element
## variables ${myiterator.key} and ${myiterator.value} are available
macro(map_iterator_next it_ref)
  list(LENGTH "${it_ref}" __map_iterator_next_length)
  if("${__map_iterator_next_length}" GREATER 1)
    list(REMOVE_AT "${it_ref}" 1)
    if(NOT "${__map_iterator_next_length}" EQUAL 2)
      list(GET "${it_ref}" 1 "${it_ref}.key")
      list(GET "${it_ref}" 0 "__map_iterator_map")
      get_property("${it_ref}.value" GLOBAL PROPERTY "${__map_iterator_map}.${${it_ref}.key}")
      set(__ans true)
    else()
      set(__ans false)
      set("${it_ref}.end" true)
    endif() 
  else()
    set("${it_ref}.end" true)
    set(__ans false)
  endif()
endmacro()





function(map_print_format)
	map_format( "${ARGN}")
  ans(res)
	message("${res}")

endfunction()




# iterates a the graph with root nodes in ${ARGN}
# in breadth first order
# expand must consider cycles
function(bfs expand)
  queue_new()
  ans(queue)
  curry(queue_push("${queue}" /1))
  ans(push)
  curry(queue_pop("${queue}"))
  ans(pop)
  graphsearch(EXPAND "${expand}" PUSH "${push}" POP "${pop}" ${ARGN})
endfunction()





  function(json_string_to_cmake str)
    # remove trailing and leading quotation marks
    string_slice("${str}" 1 -2)
    ans(str)

    string(REPLACE "\\\\;" ";" str "${str}")
    string(ASCII 8 char)
    string(REPLACE  "\\b" "${char}" str "${str}")
    string(ASCII 12 char)
    string(REPLACE  "\\f" "${char}" str "${str}")

    string(REPLACE "\\n" "\n" str "${str}")
    string(REPLACE "\\t" "\t" str "${str}")
    string(REPLACE "\\t" "\t" str "${str}")
    string(REPLACE "\\r" "\r" str "${str}")
    string(REPLACE "\\\"" "\"" str "${str}")

    string(REPLACE "\\\\" "\\" str "${str}")

    return_ref(str)
      
  endfunction()
  # converts the json-string & to a cmake string
  function(json_string_ref_to_cmake __json_string_ref_to_cmake_ref)
    json_string_to_cmake("${${__json_string_ref_to_cmake_ref}}")
    return_ans()
      
  endfunction()




# runs dfs recursively
# expects a config object:
# {
#  expand: (node)->node[] # expand the specified node,
#  enter: (node)->void # called before successors are evaluated
#  leave: (node)->void # called after node's successors were evaluated
# }
# expand has the following available vars
# - ${path} contains path to the current node (including current node)
# - ${parent} contains the node from which current node was called
# enter has the following available vars
# - all expand vars
# - ${successors} contains all direct successors of current node
# - ${enter} (boolish) can be checked to see if currently entering a node (if enter and leave callbacks are the same function)
# leave has the following available vars
# - all expand vars
# - ${successors} same as enter
# - ${leave} (boolish) can be checked to see if node is currently being left (if enter and leave callbacks are the same function)
# - ${visited} contains all nodes which were visited in recursive calls below current node
#    visited may contain duplicates depending on the graph

  function(dfs_recurse config)
    obj("${config}")
    ans(dfs_config)

    function(dfs_inner current)
      set(path ${path} ${current})
      # get successors
      map_tryget(${dfs_config} expand)
      ans(expand)

      if(NOT expand)
        message(FATAL_ERROR "expected a expand function")
      endif()

      
      rcall(successors = "${expand}"(${current}))
      
      map_tryget(${dfs_config} enter)
      ans(enter)
      if(enter)
        set(leave)
        call("${enter}"(${current}))
      endif()
      set(enter)

      

      set(parentparent ${parent})
      set(parent ${current})
      foreach(successor ${successors})
        dfs_inner(${successor})
      endforeach()
      set(parent ${parentparent})

      set(visited ${visited} ${successors} PARENT_SCOPE)
      set(visited ${visited} ${successors})

      map_tryget(${dfs_config} leave)
      ans(leave)

      if(leave)
        set(enter)
        call("${leave}"(${current}))
      endif()
      set(leave)
    endfunction()



    set(visited)
    foreach(root ${ARGN})
      set(path)
      dfs_inner(${root})
    endforeach()

    return()

  endfunction()




# returns all keys for the specified map
macro(map_keys this)
  get_property(__ans GLOBAL PROPERTY "${this}")
  #return_ref(keys)
endmacro()
# returns all keys for the specified map
#function(map_keys this)
#  get_property(keys GLOBAL PROPERTY "${this}")
#  return_ref(keys)
#endfunction()





# tries to get the value map[key] and returns NOTFOUND if
# it is not found

function(map_tryget map key)
  get_property(res GLOBAL PROPERTY "${map}.${key}")
  return_ref(res)
endfunction()

# faster way of accessing map.  however fails if key contains escape sequences, escaped vars or @..@ substitutions
# if thats the case comment out this macro
macro(map_tryget map key)
  get_property(__ans GLOBAL PROPERTY "${map}.${key}")
endmacro()





function(map_remove map key)
  map_has("${map}" "${key}")
  map_set("${map}" "${key}")
  ans(has_key)
  if(NOT has_key)
    return(false)
  endif()
  get_property(keys GLOBAL PROPERTY "${map}")
  list(REMOVE_ITEM keys "${key}")
  set_property(GLOBAL PROPERTY "${map}" "${keys}")
  return(true)
endfunction()




function(map_set_hidden map property)
  set_property(GLOBAL PROPERTY "${map}.${property}" ${ARGN})
endfunction()





  function(map_get_special map key)
    map_tryget("${map}" "__${key}__")
    return_ans()
  endfunction()
  macro(map_get_special map key)
    get_property(__ans GLOBAL PROPERTY "${map}.__${key}__")
  endmacro()





  function(map_set_special map key)
    map_set_hidden("${map}" "__${key}__" "${ARGN}")
  endfunction()




# appends a value to the end of a map entry
function(map_append map key)
  get_property(isset GLOBAL PROPERTY "${map}.${key}" SET)
	if(NOT isset)
		map_set(${map} ${key} ${ARGN})
		return()
	endif()
  set_property(GLOBAL APPEND PROPERTY "${map}.${key}" ${ARGN})
endfunction()





# set a value in the map
function(map_set this key )
  set(property_ref "${this}.${key}")
  get_property(has_key GLOBAL PROPERTY "${property_ref}" SET)
	if(NOT has_key)
		set_property(GLOBAL APPEND PROPERTY "${this}" "${key}")
	endif()
	# set the properties value
	set_property(GLOBAL PROPERTY "${property_ref}" "${ARGN}")
endfunction()








function(map_has this key )  
  get_property(res GLOBAL PROPERTY "${this}.${key}" SET)
  return(${res})
endfunction()

# faster way of accessing map.  however fails if key contains escape sequences, escaped vars or @..@ substitutions
# if thats the case comment out this macro
macro(map_has this key )  
  get_property(__ans GLOBAL PROPERTY "${this}.${key}" SET)
endmacro()








# returns true if ref is a valid reference and its type is 'map'
function(map_isvalid  ref )
	ref_isvalid("${ref}")
	ans(isref)
	if(NOT isref)
		return(false)
	endif()
	ref_gettype("${ref}")
  ans(type)
	if(NOT "${type}" STREQUAL "map")
		return(false)
	endif()
	return(true)
endfunction()





function(map_append_string map key str)
   get_property(isset GLOBAL PROPERTY "${map}.${key}" SET)
  if(NOT isset)
    map_set(${map} ${key} "${str}")
    return()
  endif()
  get_property(property_val GLOBAL PROPERTY "${map}.${key}" )
  set_property(GLOBAL PROPERTY "${map}.${key}" "${property_val}${str}")

endfunction() 





function(map_get this key)
  set(property_ref "${this}.${key}")
  get_property(property_exists GLOBAL PROPERTY "${property_ref}" SET)
  if(NOT property_exists)
    message(FATAL_ERROR "map '${this}' does not have key '${key}'")    
  endif()
  
  get_property(property_val GLOBAL PROPERTY "${property_ref}")
  return_ref(property_val)  
endfunction()
# faster way of accessing map.  however fails if key contains escape sequences, escaped vars or @..@ substitutions
# if thats the case comment out this macro
macro(map_get __map_get_map __map_get_key)
  set(__map_get_property_ref "${__map_get_map}.${__map_get_key}")
  get_property(__ans GLOBAL PROPERTY "${__map_get_property_ref}")
  if(NOT __ans)
    get_property(__map_get_property_exists GLOBAL PROPERTY "${__map_get_property_ref}" SET)
    if(NOT __map_get_property_exists)
      json_print("${__map_get_map}")

      message(FATAL_ERROR "map '${__map_get_map}' does not have key '${__map_get_key}'")    
    endif()
  endif()  
endmacro()






function(map_delete this)
	map_exists(${this} )
	ans(res)
	if(NOT res)
		return()
	endif()
	map_check(${this})
	map_keys(${this} )
	ans(keys)

	foreach(key ${keys})
		map_remove(${this} ${key})
	endforeach()
	set_property(GLOBAL PROPERTY ${this})
endfunction()




 function(map_new)
  ref_new(map)
  return_ans()
endfunction()

## optimized version
 macro(map_new)
  ref_new(map)
endmacro()





function(json)
# define callbacks for building result
  function(json_obj_begin)
    map_append_string(${context} json "{")
  endfunction()
  function(json_obj_end)
    map_append_string(${context} json "}")
  endfunction()
  function(json_array_begin)
    map_append_string(${context} json "[")
  endfunction()
  function(json_array_end)
    map_append_string(${context} json "]")
  endfunction()
  function(json_obj_keyvalue_begin)
    cmake_string_to_json("${map_element_key}")
    ans(map_element_key)
    map_append_string(${context} json "${map_element_key}:")
  endfunction()

  function(json_obj_keyvalue_end)
    math(EXPR comma "${map_length} - ${map_element_index} -1 ")
    if(comma)
      map_append_string(${context} json ",")
    endif()
  endfunction()

  function(json_array_element_end)
    math(EXPR comma "${list_length} - ${list_element_index} -1 ")
    if(comma)
      map_append_string(${context} json ",")
    endif()
  endfunction()
  function(json_literal)
    if(NOT content_length)
      map_append_string(${context} json "null")
    elseif("_${node}" MATCHES "^_((([1-9][0-9]*)([.][0-9]+([eE][+-]?[0-9]+)?)?)|true|false)$")
      map_append_string(${context} json "${node}")
    else()
      cmake_string_to_json("${node}")
      ans(node)
      map_append_string(${context} json "${node}")
    endif()
    return()

  endfunction()

   map()
    kv(value              json_literal)
    kv(map_begin          json_obj_begin)
    kv(map_end            json_obj_end)
    kv(list_begin         json_array_begin)
    kv(list_end           json_array_end)
    kv(map_element_begin  json_obj_keyvalue_begin)
    kv(map_element_end    json_obj_keyvalue_end)
    kv(list_element_end   json_array_element_end)
  end()
  ans(json_cbs)
  function_import_table(${json_cbs} json_callback)

  # function definition
  function(json)        
    map_new()
    ans(context)
    dfs_callback(json_callback ${ARGN})
    map_tryget(${context} json)
    return_ans()  
  endfunction()
  #delegate
  json(${ARGN})
  return_ans()
endfunction()




## returns true if actual has all properties (and recursive properties)
## that expected has
  function(map_match_obj actual expected)
    obj("${actual}")
    ans(actual)
    obj("${expected}")
    ans(expected)
    map_match("${actual}" "${expected}")
    return_ans()
  endfunction()




# reads a json file from the specified location
# the location may be relative (see explanantion of path() function)
# returns a map or nothing if reading fails 
function(json_read file)
    path("${file}")
    ans(file)
    if(NOT EXISTS "${file}")
      return()
    endif()
    checksum_file("${file}")
    ans(cache_key)
    file_cache_return_hit("${cache_key}")

    file(READ "${file}" data)
    json_deserialize("${data}")
    ans(data)

    file_cache_update("${cache_key}" "${data}")

    return_ref(data)
endfunction()




# adds a value to ${current_element}
function(value)
	set(options APPEND)
  	set(oneValueArgs KEY)
  	set(multiValueArgs VALUE)
  	set(prefix)
  	cmake_parse_arguments("${prefix}" "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  	if(NOT _VALUE)
		set(_VALUE ${_UNPARSED_ARGUMENTS})
  	endif()
    
    if(current_key)
      set(_KEY ${current_key})
      set(current_key PARENT_SCOPE)
    endif()

  	if(_KEY)
      if(NOT _APPEND)
  		  map_set(${current_element} "${_KEY}" "${_VALUE}")
      else()
        map_append(${current_element} "${_KEY}" "${_VALUE}")
      endif()
  	else()
		ref_append(${current_element} "${_VALUE}")
	endif()
endfunction()




## used for building hierarchical data structures
# example: 
# 
#element(package)
#  value(a)
#  value(b)
#  value(c)
#  element(d)
#  	value(I)
#  	value(KEY k 1 2 3)
#  	element(e)
#  		value(1)
#  	element(END)
#  	value(b)
#  element(END)
#element(END )
#
# the code creates a map and stores its reference in package
# (you can also get the ref if you specify a name after the END tag )
# you can access the map structur with map_* operators 
# expecially in map_navigate is useful with nested structures
function(element)
	set(options )
  	cmake_parse_arguments("" "END;MAP;LIST" "" "" ${ARGN})
  	# get name
  	set(name)
  	if(_UNPARSED_ARGUMENTS)

  		list(GET _UNPARSED_ARGUMENTS 0 name)

  	endif()
    if(NOT current_element)
      set(current_key PARENT_SCOPE)
    endif()
    if(current_key)
      set(_KEY ${current_key})
      set(current_key PARENT_SCOPE)
    endif()

  	# element ends remove element from stack and retruns
  	if(_END)
  		stack_pop(element_stack )
  		ans(res)
      stack_peek(element_stack )
      ans(new_current)
  		set(current_element ${new_current} PARENT_SCOPE)
  		# if element(END var) set var to current element
  		if(name)
  			
  			set(${name} ${res} PARENT_SCOPE)
  		endif()
  		return()
  	endif()

  	# else a new element is started . a element is always a ref
    if(_MAP)
      map_new()
      ans(res)
  	elseif(_LIST)
      list_new()
      ans(res)
    else()
      map_new()
      ans(res)
    endif()
    
  	# if element is a child element then set current_element in parent scope
  	if(current_element)
  		# if element is a named element set map entry for current element
  		if(name)
  			value(KEY ${name} ${res})
  			# map_set(${current_element} ${name} ${res})
  		else()
  			# else append it as a simple value
  			value(${res})
  		endif()
	else()
		#message(STATUS "starting top level element '${name}'")
  		# if no current elment is set the element must be named
  		if(NOT name)
  			# allow unnamed tl elements  		
  		else()
  			set(${name} ${res} PARENT_SCOPE)
  		endif()
  	endif()

  	# set curretn_element and pushback element_stack
	set(current_element ${res} PARENT_SCOPE)
  	stack_push(element_stack ${res})
endfunction()






function(map_transform  query)
	string(STRIP "${query}" query)
	string(FIND "${query}" "new" res)
	if(${res} EQUAL 0)

		string(SUBSTRING "${query}" 3 -1 query)
		json_deserialize( "${query}")
		ans(obj)

		function(map_select_visitor)
			list_isvalid(${current} )
			ans(islist)
			map_isvalid(${current} )
			ans(ismap)
			if(islist)
				ref_get(${current} )
				ans(values)
				set(transformed_values)
				foreach(value ${values})
					map_format( "${value}")
					ans(res)
					set(transformed_values "${transformed_values}" "${value}")
				endforeach()
				ref_set(${current} "${transformed_values}")
			elseif(ismap)
				map_keys(${current} )
				ans(keys)
				foreach(key ${keys})
					map_get(${current}  ${key})
					ans(value)
					map_format( "${value}")
					ans(res)
					map_set(${current} ${key} "${res}")
				endforeach()
			endif()
		endfunction()
		map_graphsearch(${obj} VISIT map_select_visitor)
		return_ref(obj)
	endif()

	set(res)
	map_format( "${query}")
	ans(res)
	return_ref(res)
endfunction()





function(map_check this)
	map_exists(${this} )
  ans(res)
	if(NOT ${res})
		message(FATAL_ERROR "map '${this}' does not exist")
	endif()
endfunction()




# compares two maps and returns true if they are equal
# order of list values is important
# order of map keys is not important
# cycles are respected.
function(map_equal lhs rhs)
	# create visited map on first call
	set(visited ${ARGN})
	if(NOT visited)
		map_new()
		ans(visited)
	endif()

	# compare lengths of lhs and rhs return false if they are not equal
	list(LENGTH lhs lhs_length)
	list(LENGTH rhs rhs_length)

	if(NOT "${lhs_length}" EQUAL "${rhs_length}")
		return(false)
	endif()


	# compare each element of list recursively and return result
	if("${lhs_length}" GREATER 1)
		math(EXPR len "${lhs_length} - 1")
		foreach(i RANGE 0 ${len})
			list(GET lhs "${i}" lhs_item)
			list(GET rhs "${i}" rhs_item)
			map_equal("${lhs_item}" "${rhs_item}" ${visited})
			ans(res)
			if(NOT res)
				return(false)
			endif()
		endforeach()
		return(true)
	endif()

	# compare strings values of lhs and rhs and return if they are equal
	if("${lhs}" STREQUAL "${rhs}")
		return(true)
	endif()

	# else lhs and rhs might be maps
	# if they are not return false
	map_isvalid(${lhs})
	ans(lhs_ismap)

	if(NOT lhs_ismap)
		return(false)
	endif()

	map_isvalid(${rhs})	
	ans(rhs_ismap)

	if(NOT rhs_ismap)
		return(false)
	endif()

	# if already visited return true as a parent call will correctly 
	# determine equality
	map_tryget(${visited} ${lhs})
	ans(lhs_isvisited)
	if(lhs_isvisited)
		return(true)
	endif()

	map_tryget(${visited} ${rhs})
	ans(rhs_isvisited)
	if(rhs_isvisited)
		return(true)
	endif()

	# set visited to true
	map_set(${visited} ${lhs} true)
	map_set(${visited} ${rhs} true)

	# compare keys of lhs and rhs	
	map_keys(${lhs} )
	ans(lhs_keys)
	map_keys(${rhs} )
	ans(rhs_keys)

	# order not important
	set_isequal(lhs_keys rhs_keys)
	ans(keys_equal)

	if(NOT keys_equal)		
		return(false)
	endif()

	# compare each property of lhs and rhs recursively
	foreach(key ${lhs_keys})

		map_get(${lhs}  ${key})
		ans(lhs_property_value)
		map_get(${rhs}  ${key})
		ans(rhs_property_value)
		
		map_equal("${lhs_property_value}" "${rhs_property_value}" ${visited})		
		ans(val_equal)
		if(NOT val_equal)
			return(false)
		endif()
	endforeach()

	## everything is equal -> return true
	return(true)
endfunction()







function(map_clone original type) 
  if("${type}" STREQUAL "DEEP")
    map_clone_deep("${original}")
    return_ans()
  elseif("${type}" STREQUAL "SHALLOW") 
    map_clone_shallow("${original}")
    return_ans()
  else()
    message(FATAL_ERROR "unknown clone type: ${type}")
  endif()
endfunction()




function(map_issubsetof result superset subset)
	map_keys(${subset} )
	ans(keys)
	foreach(key ${keys})
		map_tryget(${superset}  ${key})
		ans(superValue)
		map_tryget(${subset}  ${key})
		ans(subValue)

		map_isvalid(${superValue} )
		ans(issupermap)
		map_isvalid(${subValue} )
		ans(issubmap)
		if(issubmap AND issubmap)
			map_issubsetof(res ${superValue} ${subValue})
			if(NOT res)
				return_value(false)
			endif()
		else()
			list_isvalid(${superValue} )
			ans(islistsuper)
			list_isvalid(${subValue} )
			ans(islistsub)
			if(islistsub AND islistsuper)
				ref_get(${superValue})
				ans(superValue)
				ref_get(${subValue})
				ans(subValue)
			endif()
			list_equal( "${superValue}" "${subValue}")
			ans(res)
			if(NOT res)
				return_value(false)
			endif()
		endif()
	endforeach()
	return_value(true)
endfunction()




# executes action (key, value)->void
# on every key value pair in map
# exmpl: map = {id:'1',val:'3'}
# map_foreach("${map}" "(k,v)-> message($k $v)")
# prints 
#  id;1
#  val;3
function(map_foreach map action)
	map_keys("${map}")
	ans(keys)
	foreach(key ${keys})
		map_tryget("${map}" "${key}")
		ans(val)
		call("${action}"("${key}" "${val}"))
	endforeach()
endfunction()




# creates a union from all all maps passed as ARGN and combines them in result
# you can merge two maps by typing map_union(${map1} ${map1} ${map2})
# maps are merged in order ( the last one takes precedence)
function(map_merge )
	set(lst ${ARGN})

	map_new()
  ans(res)
  
	foreach(map ${lst})
		map_keys(${map} )
		ans(keys)
		foreach(key ${keys})
			map_tryget(${res}  ${key})
			ans(existing_val)
			map_tryget(${map}  ${key})
			ans(val)

			map_isvalid("${existing_val}" )
			ans(existing_ismap)
			map_isvalid("${val}" )
			ans(new_ismap)

			if(new_ismap AND existing_ismap)
				map_union(${existing_val}  ${val})
				ans(existing_val)
			else()
				
				map_set(${res} ${key} ${val})
			endif()
		endforeach()
	endforeach()
	return(${res})
endfunction()







function(map_clone_deep original)
  map_clone_shallow("${original}")
  ans(result)
    
  map_isvalid("${result}" )
  ans(ismap)
  if(ismap) 
    map_keys("${result}" )
    ans(keys)
    foreach(key ${keys})
      map_get(${result}  ${key})
      ans(value)
      map_clone_deep("${value}")
      ans(cloned_value)
      map_set(${result} ${key} ${cloned_value})
    endforeach()
  endif()
  return_ref(result)
endfunction()





function(map_clone_shallow original)
  map_isvalid("${original}" )
  ans(ismap)
  if(ismap)
    map_new()
    ans(result)
    map_keys("${original}" )
    ans(keys)
    foreach(key ${keys})
      map_get("${original}"  "${key}")
      ans(value)
      map_set("${result}" "${key}" "${value}")
    endforeach()
    return(${result})
  endif()

  ref_isvalid("${original}")
  ans(isref)
  if(isref)
    ref_get(${original})
    ans(res)
    ref_gettype(${original})
    ans(type)
    ref_new(${type})
    ans(result)
    ref_set(${result} ${res})
    return(${result})
  endif()

  # everythign else is a value type and can be returned
  return_ref(original)

endfunction()




# creates a union from all all maps passed as ARGN and combines them in the first
# you can merge two maps by typing map_union(${map1} ${map1} ${map2})
# maps are merged in order ( the last one takes precedence)
function(map_union)
	set(lst ${ARGN})
	list_pop_front(lst)
	ans(res)
	if(NOT res)
		message(FATAL_ERROR "map_union: no maps passed")
	endif()
	# loop through the keys of every map	
	foreach(map ${lst})
		map_keys(${map} )
		ans(keys)
		foreach(key ${keys})
			map_tryget(${map}  ${key})
			ans(val)
			map_set(${res} ${key} ${val})
		endforeach()
	endforeach()
	return(${res})
endfunction()






## compares two maps for value equality
## lhs and rhs may be objectish 
function(map_equal_obj lhs rhs)
  obj("${lhs}")
  ans(lhs)
  obj("${rhs}")
  ans(rhs)
  map_equal("${lhs}" "${rhs}")
  return_ans()
endfunction()




# iterates a the graph with root nodes in ${ARGN}
# in depth first order
# expand must consider cycles
function(dfs expand)
  stack_new()
  ans(stack)
  curry(stack_push("${stack}" /1))
  ans(push)
  curry(stack_pop("${stack}" ))
  ans(pop)
  graphsearch(EXPAND "${expand}" PUSH "${push}" POP "${pop}" ${ARGN})
endfunction()





## imports the specified properties into the current scope
## e.g map = {a:1,b:2,c:3}
## map_import_properties(${map} a c)
## -> ${a} == 1 ${b} == 2
  function(map_import_properties map)
    foreach(key ${ARGN})
      map_tryget("${map}" "${key}")
      ans(value)
      set(${key} ${value} PARENT_SCOPE)
    endforeach()
    return()
  endfunction()






function(map_select  query)
# select something from a list 
# using syntax 'from a in lstA, b in lstB select {a.k1}{b.k1}'
# see map_transform and map_foreach
	string(REGEX REPLACE "from(.*)select(.*)" "\\1" _foreach_args "${query}")
	string(REGEX REPLACE "from(.*)select (.*)" "\\2" _select_args "${query}")

	list_new()
	ans(_result_list)
	function(_map_select_foreach_action)
		map_transform( "${_select_args}")
		ans(res)
		ref_append(${_result_list} "${res}")
	endfunction()
	map_foreach( _map_select_foreach_action "${_foreach_args}")
	ref_get( ${_result_list} )
	ans(_result_list)
	return_ref(_result_list)

endfunction()

function(map_select_property)

	endfunction()




function(map_navigate_set navigation_expression)
	cmake_parse_arguments("" "FORMAT" "" "" ${ARGN})
	set(args)
	if(_FORMAT)
		foreach(arg ${_UNPARSED_ARGUMENTS})
			map_format( "${arg}")
			ans(formatted_arg)
			list(APPEND args "${formatted_arg}")
		endforeach()
	else()
		set(args ${_UNPARSED_ARGUMENTS})
	endif()
	# path is empty => ""
	if(navigation_expression STREQUAL "")
		return_value("")
	endif()

	# split off reference from navigation expression
	unset(ref)
	string(REGEX MATCH "^[^\\[|\\.]*" ref "${navigation_expression}")
	string(LENGTH "${ref}" len )
	string(SUBSTRING "${navigation_expression}" ${len} -1 navigation_expression)

	# rest of navigation expression is empty, first is a var
	if(NOT navigation_expression)

		set(${ref} "${args}" PARENT_SCOPE)
		return()
	endif()
	



	# match all navigation expression parts
	string(REGEX MATCHALL  "(\\[([0-9][0-9]*)\\])|(\\.[a-zA-Z0-9_\\-][a-zA-Z0-9_\\-]*)" parts "${navigation_expression}")
	
	# loop through parts and try to navigate 
	# if any part of the path is invalid return ""

	set(current "${${ref}}")
	
	
	while(parts)
		list(GET parts 0 part)
		list(REMOVE_AT parts 0)
		
		string(REGEX MATCH "[a-zA-Z0-9_\\-][a-zA-Z0-9_\\-]*" index "${part}")
		string(SUBSTRING "${part}" 0 1 index_type)	



		#message("current ${current}, parts: ${parts}, current_part: ${part}, current_index ${index} current_type : ${index_type}")
		# first one could not be ref so create ref and set output
		ref_isvalid("${current}")
		ans(isref)
		
		if(NOT isref)
			map_new()
    	ans(current)
			set(${ref} ${current} PARENT_SCOPE)
		endif()		
		
		# end of navigation string reached, set value
		if(NOT parts)
			map_set(${current} ${index} "${args}")
			return()
		endif()

		
		map_tryget(${current}  "${index}")
		ans(next)
		# create next element in change
		if(NOT next)
			map_new()
    	ans(next)
			map_set(${current} ${index} ${next})
		endif()

		# if no next element exists its an error
		if(NOT next)
			message(FATAL_ERROR "map_navigate_set: path is invalid")
		endif()

		set(current ${next})

		
	endwhile()
endfunction()




# a convenience function for navigating maps
# nav(a.b.c) -> returns memver c of member b of map a
# nav(a.b.c 3) ->sets member c of member b of map a to 3 (creating any missing maps along the way)
# nav(a.b.c = d.e.f) -> assignes the value of d.e.f to a.b.c
# nav(a.b.c += d.e) adds the value of d.e to the value of a.b.c
# nav(a.b.c -= d.e) removes the value of d.e from a.b.c
# nav(a.b.c FORMAT "{d.e}@{d.f}") formats the string and assigns a.b.c to it
# nav(a.b.c CLONE_DEEP d.e.f) clones the value of d.e.f depely and assigns it to a.b.c
function(nav navigation_expression)
  set(args ${ARGN})
  if("${args}_" STREQUAL "_")
    map_navigate(res "${navigation_expression}")
    return(${res})
  endif()

  if("${ARGN}" STREQUAL "UNSET")
    map_navigate_set("${navigation_expression}")
    return()
  endif()


  set(args ${ARGN})
  list_peek_front(args)
  ans(first)

  if("_${first}" STREQUAL _CALL)
    call(${args})
    ans(args)
  elseif("_${first}" STREQUAL _FORMAT)
    list_pop_front( args)
    map_format("${args}")  
    ans(args)
  elseif("_${first}" STREQUAL _APPEND OR "_${first}" STREQUAL "_+=")
    list_pop_front(args)
    map_navigate(cur "${navigation_expression}")
    map_navigate(args "${args}")
    set(args ${cur} ${args})
  elseif("_${first}" STREQUAL _REMOVE OR "_${first}" STREQUAL "_-=")
    list_pop_front(args)
    map_navigate(cur "${navigation_expression}")
    map_navigate(args "${args}")
    if(cur)
      list(REMOVE_ITEM cur "${args}")
    endif()
    set(args ${cur})
 elseif("_${first}" STREQUAL _ASSIGN OR "_${first}" STREQUAL _= OR "_${first}" STREQUAL _*)
    list_pop_front( args)
    map_navigate(args "${args}")
    
 elseif("_${first}" STREQUAL _CLONE_DEEP)
    list_pop_front( args)
    map_navigate(args "${args}")
    map_clone_deep("${args}")
    ans(args)
 elseif("_${first}" STREQUAL _CLONE_SHALLOW)
    list_pop_front( args)
    map_navigate(args "${args}")
    map_clone_shallow("${args}")
    ans(args)
  endif()

  # this is a bit hacky . if a new var is created by map_navigate_set
  # it is propagated to the PARENT_SCOPE
  string(REGEX REPLACE "^([^.]*)\\..*" "\\1" res "${navigation_expression}")
  map_navigate_set("${navigation_expression}" ${args})
  set(${res} ${${res}} PARENT_SCOPE)

  return_ref(args)
endfunction()




#navigates a map structure
# use '.' and '[]' operators to select next element in map
# e.g.  map_navigate(<map_ref> res "propa.propb[3].probc[3][4].propd")
function(map_navigate result navigation_expression)
	# path is empty => ""
	if(navigation_expression STREQUAL "")
		return_value("")
	endif()

	# if navigation expression is a simple var just return it
	if("${navigation_expression}")
		return_value(${${navigation_expression}})
	endif()

	# check for dereference operator
	set(deref false)
	if("${navigation_expression}" MATCHES "^\\*")
		set(deref true)
		string(SUBSTRING "${navigation_expression}" 1 -1 navigation_expression)
	endif()

	# split off reference from navigation expression
	unset(ref)
	#_message("${navigation_expression}")
	string(REGEX MATCH "^[^\\[|\\.]*" ref "${navigation_expression}")
	string(LENGTH "${ref}" len )
	string(SUBSTRING "${navigation_expression}" ${len} -1 navigation_expression )

	

	# if ref is a ref to a ref dereference it :D 
	set(not_defined true)
	if(DEFINED ${ref})
		set(ref ${${ref}})
		set(not_defined false)
	endif()

	# check if ref is valid
	ref_isvalid("${ref}")
	ans(is_ref)
	if(NOT is_ref)
		if(not_defined)
			return_value()
		endif()
		set(${result} "${ref}" PARENT_SCOPE)

		return()
		message(FATAL_ERROR "map_navigate: expected a reference but got '${ref}'")
	endif()

	# match all navigation expression parts
	string(REGEX MATCHALL  "(\\[([0-9][0-9]*)\\])|(\\.[a-zA-Z0-9_\\-][a-zA-Z0-9_\\-]*)" parts "${navigation_expression}")
	
	# loop through parts and try to navigate 
	# if any part of the path is invalid return ""
	set(current "${ref}")
	foreach(part ${parts})
		string(REGEX MATCH "[a-zA-Z0-9_\\-][a-zA-Z0-9_\\-]*" index "${part}")
		string(SUBSTRING "${part}" 0 1 index_type)	
		if(index_type STREQUAL ".")
			# get by key
			map_tryget(${current}  "${index}")
			ans(current)
		elseif(index_type STREQUAL "[")
			message(FATAL_ERROR "map_navigate: indexation '[<index>]' is not supported")
			# get by index
			ref_get( ${current} )
			ans(lst)
			list(GET lst ${index} keyOrValue)
			map_tryget(${current}  ${keyOrValue})
			ans(current)
			if(NOT current)
				set(current "${keyOrValue}")
			endif()
		endif()
		if(NOT current)
			return_value("${current}")
		endif()
	endforeach()
	if(deref)
		ref_isvalid("${current}"  )
		ans(is_ref)
		if(is_ref)
			ref_get("${current}" )
			ans(current)
		endif()
	endif()
	# current  contains the navigated value
	set(${result} "${current}" PARENT_SCOPE)
endfunction()
	






  function(set_at ref)
    set(args ${ARGN})
    list_pop_front(args)
    ans(first)



    if(NOT args)
      # single value
      set(${ref} ${first})
    elseif("${first}" MATCHES "^\\[.*\\]$")
      # indexer
      list(LENGTH ${ref} len)
      string(REGEX REPLACE "\\[(.*)\\]" "\\1" indexer "${first}")

      if("${indexer}_" STREQUAL "_")
        set(indexer ${len})
      endif()   

      if("${indexer}" EQUAL ${len})
        set(indexer -1)
      endif()


      list_set_at(${ref} ${indexer} ${args})
    

    else()  
      # map key
      map_isvalid("${${ref}}")
      ans(is_map)
      if(NOT __ans)
        map_new()
        ans(${ref})
      endif()

      list(GET args 0 indexer)

      if("${indexer}" MATCHES "^\\[.*\\]$")
        list_pop_front(args)
        map_tryget(${${ref}} ${first})
        ans(val)
        list(LENGTH val len)
        string(REGEX REPLACE "\\[(.*)\\]" "\\1" indexer "${indexer}")
        if("${indexer}_" STREQUAL _)
          set(indexer ${len})
        endif()
        if(NOT "${indexer}" LESS ${len})
          set(indexer -1)
        endif()
        list_set_at(val ${indexer} ${args})

        set(args ${val})

      endif()

      map_set("${${ref}}" "${first}" ${args})

      # key
    endif()

    set(${ref} ${${ref}} PARENT_SCOPE)
    return_ref(${ref})

  endfunction()








function(map_navigate_set_if_missing navigation_expr)
  map_navigate(result ${navigation_expr})
  if(NOT result OR "${result}" STREQUAL "${navigation_expr}")
    map_navigate_set("${navigation_expr}" ${ARGN})
  endif() 
endfunction()





## captures a list of variable as a key value pair
function(var)
  foreach(var ${ARGN})
    kv("${var}" "${${var}}")
  endforeach()
endfunction()




function(map)
  set(key ${ARGN})

  # get current map
  stack_peek(:quick_map_map_stack)
  ans(current_map)

  # get current key
  stack_peek(:quick_map_key_stack)
  ans(current_key)

  if(ARGN)
    set(current_key ${ARGV0})
  endif()

  # create new current map
  map_new()
  ans(new_map)


  # add map to existing map
  if(current_map)
    key("${current_key}")
    val("${new_map}")
  endif()


  # push new map and new current key on stacks
  stack_push(:quick_map_map_stack ${new_map})
  stack_push(:quick_map_key_stack "")

  return_ref(new_map)
endfunction()



## map() -> <address>
## 
## begins a new map returning its address
## map needs to be ended via end()
function(map)
  if(NOT ARGN STREQUAL "")
    key("${ARGN}")
  endif()
  map_new()
  ans(ref)
  val(${ref})
  stack_push(quickmap ${ref})
  return_ref(ref)
endfunction()





function(kv key)
  key("${key}")
  val(${ARGN})
endfunction()






function(end)
  # remove last key from key stack and last map from map stack
  # return the popped map
  stack_pop(:quick_map_key_stack)
  stack_pop(:quick_map_map_stack)
  return_ans()
endfunction()



## end() -> <current value>
##
## ends the current key, ref or map and returns the value
## 
function(end)
  stack_pop(quickmap)
  ans(ref)

  if(NOT ref)
    message(FATAL_ERROR "end() not possible ")
  endif()
    
  string_take_address(ref)
  ans(current_ref)

  return_ref(current_ref)
endfunction()





function(val)
  # appends the values to the current_map[current_key]
  stack_peek(:quick_map_map_stack)
  ans(current_map)
  stack_peek(:quick_map_key_stack)
  ans(current_key)
  if(NOT current_map)
    set(res ${ARGN})
    return_ref(res)
  endif()
  map_append("${current_map}" "${current_key}" "${ARGN}")
endfunction()



## val(<val ...>) -> <any...>
##
## adds a val to current property or ref
##
function(val)
  set(args ${ARGN})
  stack_peek(quickmap)
  ans(current_ref)
  
  if(NOT current_ref)
    return()
  endif()
  ## todo check if map 
  ref_append("${current_ref}" ${args})
  return_ref(args)
endfunction()






## ref() -> <address> 
## 
## begins a new reference value and returns its address
## ref needs to be ended via end() call
function(ref)
  if(NOT ARGN STREQUAL "")
    key("${ARGN}")
  endif()
  ref_new()
  ans(ref)
  val(${ref})
  stack_push(quickmap ${ref})   
  return_ref(ref)
endfunction()





function(key key)
  # check if there is a current map
  stack_peek(:quick_map_map_stack)
  ans(current_map)
  if(NOT current_map)
    message(FATAL_ERROR "cannot set key for non existing map be sure to call first map() before first key()")
  endif()
  # set current key
  stack_pop(:quick_map_key_stack)
  stack_push(:quick_map_key_stack "${key}")
endfunction()


## key() -> <void>
##
## starts a new property for a map - may only be called
## after key or map
## fails if current ref is not a map
function(key key)
  stack_pop(quickmap)
  ans(current_key)

  string_take_address(current_key)
  ans(current_ref)
 
  map_isvalid("${current_ref}")
  ans(ismap)
  if(NOT ismap)
    message(FATAL_ERROR "expected a map before key() call")
  endif()


  map_set("${current_ref}" "${key}" "")
  stack_push(quickmap "${current_ref}.${key}")
  return()
endfunction()






function(json_indented)
  # define callbacks for building result
  function(json_obj_begin_indented)
   # message(PUSH_AFTER "json_obj_begin_indented(${ARGN})")
    map_tryget(${context} indentation)
    ans(indentation)
    map_append_string(${context} json "{\n")
    map_append_string(${context} indentation " ")
  endfunction()
  function(json_obj_end_indented)
    #message(POP "json_obj_end_indented(${ARGN})")
    map_tryget(${context} indentation)
    ans(indentation)
    string(SUBSTRING "${indentation}" 1 -1 indentation)
    map_set(${context} indentation "${indentation}")
    map_append_string(${context} json "${indentation}}")

  endfunction()
  function(json_array_begin_indented)
    #message(PUSH_AFTER "json_array_begin_indented(${ARGN}) ${context}")
    map_tryget(${context} indentation)
    ans(indentation)
    map_append_string(${context} json "[\n")
    map_append_string(${context} indentation " ")
    
  endfunction()
  function(json_array_end_indented)
   # message(POP "json_array_end_indented(${ARGN}) ${context}")
    map_tryget(${context} indentation)
    ans(indentation)
    string(SUBSTRING "${indentation}" 1 -1 indentation)
    map_set(${context} indentation "${indentation}")
    map_append_string(${context} json "${indentation}]")
  endfunction()
  function(json_obj_keyvalue_begin_indented)
   # message("json_obj_keyvalue_begin_indented(${key} ${ARGN}) ${context}")
    map_tryget(${context} indentation)
    ans(indentation)
    map_append_string(${context} json "${indentation}\"${map_element_key}\":")
  endfunction()

  function(json_obj_keyvalue_end_indented)
    #message("json_obj_keyvalue_end_indented(${ARGN}) ${context}")
    math(EXPR comma "${map_length} - ${map_element_index} -1 ")
    if(comma)
      map_append_string(${context} json ",")
    endif()
    
    map_append_string(${context} json "\n")
  endfunction()

  function(json_array_element_begin_indented)
   # message("json_array_element_begin_indented(${ARGN}) ${context}")
    map_tryget(${context} indentation)
    ans(indentation)
    map_append_string(${context} json "${indentation}")
  endfunction()
  function(json_array_element_end_indented)
   #message("json_array_element_end_indented(${ARGN}) ${context}")
    math(EXPR comma "${list_length} - ${list_element_index} -1 ")
    if(comma)
      map_append_string(${context} json ",")
    endif()
    map_append_string(${context} json "\n")
  endfunction()
  function(json_literal_indented)
    if(NOT content_length)
      map_append_string(${context} json "null")
    elseif("_${node}" MATCHES "^_(0|(([1-9][0-9]*)([.][0-9]+([eE][+-]?[0-9]+)?)?)|true|false)$")
      map_append_string(${context} json "${node}")
    else()
      cmake_string_to_json("${node}")
      ans(node)
      map_append_string(${context} json "${node}")
    endif()
    return()
  endfunction()

   map()
    kv(value              json_literal_indented)
    kv(map_begin          json_obj_begin_indented)
    kv(map_end            json_obj_end_indented)
    kv(list_begin         json_array_begin_indented)
    kv(list_end           json_array_end_indented)
    kv(map_element_begin  json_obj_keyvalue_begin_indented)
    kv(map_element_end    json_obj_keyvalue_end_indented)
    kv(list_element_begin json_array_element_begin_indented)
    kv(list_element_end   json_array_element_end_indented)
  end()
  ans(json_cbs)
  function_import_table(${json_cbs} json_indented_callback)

  # function definition
  function(json_indented)        
    map_new()
    ans(context)
    dfs_callback(json_indented_callback ${ARGN})
    map_tryget(${context} json)
    return_ans()  
  endfunction()
  #delegate
  json_indented(${ARGN})
  return_ans()
endfunction()





# emits events parsing a list of map type elements 
# expects a callback function that takes the event type string as a first argument
# follwowing events are called (available context variables are listed as subelements: 
# value
#   - list_length (may be 0 or 1 which is good for a null check)
#   - content_length (contains the length of the content)
#   - node (contains the value)
# list_begin
#   - list_length (number of elements the list contains)
#   - content_length (accumulated length of list elements + semicolon separators)
#   - node (contains all values of the lsit)
# list_end
#   - list_length(number of elements in list)
#   - node (whole list)
#   - list_char_length (length of list content)
#   - content_length (accumulated length of list elements + semicolon separators)
# list_element_begin
#   - list_length(number of elements in list)
#   - node (whole list)
#   - list_char_length (length of list content)
#   - content_length (accumulated length of list elements + semicolon separators)
#   - list_element (contains current list element)
#   - list_element_index (contains current index )   
# list_element_end
#   - list_length(number of elements in list)
#   - node (whole list)
#   - list_char_length (length of list content)
#   - content_length (accumulated length of list elements + semicolon separators)
#   - list_element (contains current list element)
#   - list_element_index (contains current index )
# visited_reference
#   - node (contains ref to revisited map)
# unvisited_reference
#   - node (contains ref to unvisited map)
# map_begin
#   - node( contains ref to map)
#   - map_keys (contains all keys of map)
#   - map_length (contains number of keys of map)
# map_end
#   - node( contains ref to map)
#   - map_keys (contains all keys of map)
#   - map_length (contains number of keys of map)
# map_element_begin
#   - node( contains ref to map)
#   - map_keys (contains all keys of map)
#   - map_length (contains number of keys of map)
#   - map_element_key (current key)
#   - map_element_value (current value)
#   - map_element_index (current index)
# map_element_end
#   - node( contains ref to map)
#   - map_keys (contains all keys of map)
#   - map_length (contains number of keys of map)
#   - map_element_key (current key)
#   - map_element_value (current value)
#   - map_element_index (current index)
function(dfs_callback callback)
  # inner function
  function(dfs_callback_inner node)
    map_isvalid("${node}")
    ans(ismap)
    if(NOT ismap)
      list(LENGTH node list_length)
      string(LENGTH "${node}" content_length)
      if(${list_length} LESS 2)
        dfs_callback_emit(value)
      else()
        dfs_callback_emit(list_begin) 
        set(list_element_index 0)
        foreach(list_element ${node})
          list_push_back(path "${list_element_index}")
          dfs_callback_emit(list_element_begin)
          dfs_callback_inner("${list_element}")
          dfs_callback_emit(list_element_end)
          list_pop_back(path)
          math(EXPR list_element_index "${list_element_index} + 1")
        endforeach()
        dfs_callback_emit(list_end)
      endif()
      return()
    endif()

    map_tryget(${visited} "${node}")
    ans(was_visited)

    if(was_visited)
      dfs_callback_emit("visited_reference")
      return()
    else()
      dfs_callback_emit("unvisited_reference")
    endif()
    map_set(${visited} "${node}" true)

    map_keys(${node})
    ans(map_keys)

    list(LENGTH map_keys map_length)

    dfs_callback_emit(map_begin)

    
    set(map_element_index 0)
    foreach(map_element_key ${map_keys})
      map_tryget(${node} ${map_element_key})
      ans(map_element_value)
      list_push_back(path "${map_element_key}")
      dfs_callback_emit(map_element_begin)

      dfs_callback_inner("${map_element_value}")

      dfs_callback_emit(map_element_end)
      list_pop_back(path)

      math(EXPR map_element_index "${map_element_index} + 1")
    endforeach()


    dfs_callback_emit(map_end "${node}" )
  endfunction()

  function(dfs_callback callback)
    curry("${callback}"(/1) as dfs_callback_emit)

    map_new()
    ans(visited)

   # foreach(arg ${ARGN})
   set(path)
    dfs_callback_inner("${ARGN}")
   # endforeach()
    return()
  endfunction()
  dfs_callback("${callback}" ${ARGN})
  return_ans()
endfunction()




# query a a list of maps with linq like syntax
# ie  from package in packages where package.id STREQUAL package1 AND package.version VERSION_GREATER 1.3
# packages is a list of maps and package is the name for a single pakcage used in the where clause
# 
function(map_where  query)
	set(regex "from (.*) in (.*) where (.*)")
	string(REGEX REPLACE "${regex}" "\\1" ref "${query}")
	string(REGEX REPLACE "${regex}" "\\2" source "${query}")
	string(REGEX REPLACE "${regex}" "\\3" where "${query}")
	string_split( "${where}" " ")
	ans(where_parts)
	set(res)
	foreach(${ref} ${${source}})
		map_format( "${where_parts}")
		ans(current_where)
		if(${current_where})
			set(res ${res} ${${ref}})
		endif()
	endforeach()	 
	return_ref(res)
endfunction()





function(map_format input)
	string(REGEX MATCHALL "{([^}{]*)}" matches "${input}")
	foreach(match ${matches})
		string(LENGTH ${match} len)
		math(EXPR len "${len} - 2")
		string(SUBSTRING ${match} 1 ${len} nav)
		map_navigate(res "${nav}")
		# escape regex chars ([] .*)
		string(REGEX REPLACE "(\\]|\\.|\\[|\\*)" "\\\\\\1" match "${match}")
		string(REGEX REPLACE "${match}" "${res}" input "${input}")
	endforeach()
	return_ref(input)
endfunction()






  function(map_decycle val)
    map_new()
    ans(visited_nodes)
    map_set(global ref_count 0)
    set(map_decycle_flatten true)
    function(decycle_successors result node)
      message("getting successors")
      
      map_isvalid(${node} )
      ans(ismap)
      ref_isvalid(${node})
      ans(isref)
      set(potential_successors)
      if(ismap)
        map_keys(${node} )
        ans(keys)
        foreach(key ${keys})
          map_get(${node}  ${key} )
          ans(val)
          ref_isvalid(${val})
          ans(isref)
          if(isref)

            map_tryget(${visited_nodes}  "${val}")
            ans(ref_id)
            if(ref_id)
              set(val ${ref_id})
              map_set(${node} ${key} ${ref_id})
            endif()
          endif()

          list(APPEND potential_successors ${val})
        endforeach()
      elseif(isref)
        ref_get(${node})
        ans(res)
        set(transformed_res)
        foreach(element ${res})
          ref_isvalid(${element})
          ans(isref)
          if(isref)
            map_tryget(${visited_nodes}  "${element}")
            ans(ref_id)
            if(ref_id)
              set(element ${ref_id})
            endif()
          endif()
          list(APPEND transformed_res ${element})
        endforeach()
        ref_set(${node} "${transformed_res}")
        list(APPEND potential_successors ${res})
      endif()

      set(successors)  
      foreach(potential_successor ${potential_successors})
        ref_isvalid(${potential_successor})
        ans(isref)
        if(isref)
         # ref_print(${visited_nodes})
          map_has(${visited_nodes} "${potential_successor}")
          ans(was_visited)
          if(NOT was_visited)
            list(APPEND successors ${potential_successor})
          
          endif()

          else()
        endif()
      endforeach()

      set(${result} ${successors} PARENT_SCOPE)
    endfunction()


    function(decycle_visit cancel value)
      message("visiting")
      map_isvalid(${value} )
      ans(ismap)
      ref_isvalid(${value})
      ans(isref)
      if(isref)
        map_tryget(global ref_count)
        ans(ref_count)
        
        math(EXPR ref_count "${ref_count} + 1")
        map_set(global ref_count ${ref_count})
        map_set(${visited_nodes} ${value} "\$${ref_count}")   
        if(ismap)
          map_set(${value} "\$id" "\$${ref_count}")
          
        endif()


        message("found ref")
      endif()

    endfunction()

    map_graphsearch(VISIT decycle_visit SUCCESSORS decycle_successors ${val})

    #ref_print(${visited_nodes})
    #ref_print(${val})
  endfunction()




# not finished
function(table_serialize)  
  objs(${ARGN})  
  ans(lines)


  map_new()
  ans(column_layout)

  set(allkeys)

  # get column_layout and col sizes
  foreach(line ${lines})
    map_keys(${line})
    ans(keys)
    
    foreach(key ${keys})  
      map_tryget(${column_layout} ${key})
      ans(res)
      
      map_tryget(${line} ${key})
      ans(val)
      string(LENGTH "${val}" len)
        
      if(${len} GREATER "0${res}")
        map_set(${column_layout} ${key} "${len}")
      endif()
    endforeach()
  endforeach()


  map_keys(${column_layout})
  ans(headers)
  set(res)
  set(separator)
  set(layout)
  set(first true)
  foreach(header ${headers})
    if(first)
      set(first false)
    else()
      set(res "${res} ")
      set(separator "${separator} ")
    endif()

    map_tryget(${column_layout} "${header}")
    ans(size)
    string_pad("${header}" "${size}")
    ans(header)    
    set(res "${res}${header}")
    string_repeat("=" "${size}")
    ans(sep)
    set(separator "${separator}${sep}")
  endforeach()

  set(res "${res}\n${separator}\n")
  

  foreach(line ${lines})
    set(first true)    
    foreach(header ${headers})
      if(first)
        set(first false)
      else()
        set(res "${res} ")      
      endif()
      map_tryget(${column_layout} "${header}")
      ans(size)
      map_tryget(${line} "${header}")
      ans(val)
      string_pad("${val}" ${size})
      ans(val)
      set(res "${res}${val}")
    endforeach()
    set(res "${res}\n")
  endforeach()

  return_ref(res)
endfunction()




# parses a table as is output by win32 commands like tasklist
# the format is
# header1 header2 header3
# ======= ======= =======
# val1    val2    val3
# val4    val5    val6
# not that the = below the header is used as the column width and must be the max length of any value in 
# column including the header
# returns a list of <row> where row is a map and the headers are the keys   (values are trimmed from whitespace)
# the example above results in 
# {
#   "header1":"val1",
#   "header2":"val2",
#   "header3":"val3"
# }
#
function(table_deserialize input)
  string_lines("${input}")
  ans(lines)
  list_pop_front(lines)
  ans(firstline)  
  list_pop_front(lines)    
  ans(secondline)
  list_pop_front(lines)    
  ans(thirdline)

  string(REPLACE "=" "." line_match "${thirdline}")
  string_split("${line_match}" " ")
  ans(parts)
  list(LENGTH parts cols) 
  set(linematch)
  set(first true)
  foreach(part ${parts})
    if(first)
      set(first false)
    else()
      set(linematch "${linematch} ")
    endif()
    set(linematch "${linematch}(${part})")
  endforeach()

  set(headers __empty) ## empty is there to buffer so that headers can be index 1 based instead of 0 based
  foreach(idx RANGE 1 ${cols})
    string(REGEX REPLACE "${linematch}" "\\${idx}" header "${secondline}")
    string(STRIP "${header}" header)
    list(APPEND headers ${header})
  endforeach()



  set(result)
  foreach(line ${lines})
    map_new()
    ans(l)
    foreach(idx RANGE 1 ${cols})
      string(REGEX REPLACE "${linematch}" "\\${idx}" col "${line}")
      string(STRIP "${col}" col)
      list_get(headers ${idx})
      ans(header)
      map_set(${l} "${header}" "${col}")        
    endforeach()
    list(APPEND result ${i})
  endforeach()

  return_ref(result)
endfunction()






  function(cmake_string_unescape str)
    string(REPLACE "\\\"" "\"" str "${str}")
    string(REPLACE "\\\\" "\\" str "${str}")
    string(REPLACE "\\(" "(" str "${str}")
    string(REPLACE "\\)" ")" str "${str}")
    string(REPLACE "\\$" "$" str "${str}")
    string(REPLACE "\\#" "#" str "${str}")
    string(REPLACE "\\^" "^" str "${str}")
    string(REPLACE "\\t" "\t" str "${str}")
    string(REPLACE "\\;" ";"  str "${str}")
    string(REPLACE "\\n" "\n" str "${str}")
    string(REPLACE "\\r" "\r" str "${str}")
    string(REPLACE "\\0" "\0" str "${str}")
    string(REPLACE "\\ " " " str "${str}")
    return_ref(str)
  endfunction()




function(json_tokenize result json)
	set(regex "(\\{|\\}|:|,|\\[|\\]|\"(\\\\.|[^\"])*\")")
	string(REGEX MATCHALL "${regex}" matches "${json}")

	# replace brackets with angular brackets because
	# normal brackes are not handled properly by cmake
	string(REPLACE  ";[;" ";<;" matches "${matches}")
	string(REPLACE ";];" ";>;" matches "${matches}")
	string(REPLACE "[" "†" matches "${matches}")
	string(REPLACE "]" "‡" matches "${matches}")

	set(tokens)
	foreach(match ${matches})
		string_char_at( 0 "${match}")
		ans(char)
		if("${char}" STREQUAL "[")
			string_char_at( -2 "${match}")
			ans(char)
			if(NOT "${char}" STREQUAL "]")
				message(FATAL_ERROR "json syntax error: no closing ']' instead: '${char}' ")
			endif()
			string(LENGTH "${match}" len)
			math(EXPR len "${len} - 2")
			string(SUBSTRING ${match} 1 ${len} array_values)
			set(tokens ${tokens} "<")
			foreach(submatch ${array_values})
				set(tokens ${tokens} ${submatch} )
			endforeach()
			set(tokens ${tokens} ">")
		else()
			set(tokens ${tokens} ${match})
		endif()
	endforeach()

	set(${result} ${tokens} PARENT_SCOPE)
endfunction()





  ## quickly extracts string properties values from a json string
  ## useful for large json files with unique property keys
  function(json_extract_string_value key data)
    regex_escaped_string("\"" "\"") 
    ans(regex)

    set(key_value_regex "\"${key}\" *: ${regex}")
    string(REGEX MATCHALL  "${key_value_regex}" matches "${data}")
    set(values)
    foreach(match ${matches})
      string(REGEX REPLACE "${key_value_regex}" "\\1" match "${match}")
      list(APPEND values "${match}")
    endforeach() 
    return_ref(values)
  endfunction()




function(json_serialize value)
	set(recursive_args)
	# indent
	if(ARGN)
		set(list_to_array)
		list(FIND args "LIST_TO_ARRAY" idx)
		if(NOT ${idx} LESS 0)
			set(list_to_array true)
			set(recursive_args LIST_TO_ARRAY)
		endif()

		set(args ${ARGN})
		list(FIND args "INDENTED" idx)
		if(NOT ${idx} LESS 0)
			json_serialize( "${value}")
			ans(json)
			json_tokenize(tokens "${json}")
			json_format_tokens(indented "${tokens}")
			return_ref(indented)
		endif()	


	endif()


	# if value is empty return an empty string
	if(NOT value)
		return()
	endif()
	# if value is a not ref return a simple string value
	ref_isvalid("${value}")
	ans(is_ref)
	if(NOT is_ref)
		json_escape( "${value}")
		ans(value)
		set(value "\"${value}\"" )
		return_ref(value)
	endif()

	# get ref type
	# here map, list and * will be differantited
	# resulting object, array and string respectively
	set(ref_type)
	ref_gettype("${value}")
	ans(ref_type)
	if("${ref_type}" STREQUAL map)
		set(res)
		map_keys(${value} )
		ans(keys)
		foreach(key ${keys})
		#	message("value '${value}' key '${key}'")
			map_get(${value} ${key})	
			ans(val)
			#message_indent_push()
			json_serialize( "${val}" ${recursive_args} )
			ans(serialized_value)
		#	message_indent_pop()
			if(serialized_value)
				set(res "${res},\"${key}\":${serialized_value}")
			endif()				
		endforeach()
		string(LENGTH "${res}" len)
		if(${len} GREATER 0)
			string(SUBSTRING "${res}" 1 -1 res)
		endif()
		
			set(res "{${res}}")
		return_ref(res)
	elseif("${ref_type}" STREQUAL list)
		ref_get( ${value} )
		ans(lst)
		set(res "")
		foreach(val ${lst})
			json_serialize( "${val}" ${recursive_args})			
			ans(serialized_value)
			set(res "${res},${serialized_value}")				
		endforeach()	

		string(LENGTH "${res}" len)
		if(${len} GREATER 0)				
			string(SUBSTRING "${res}" 1 -1  res)
		endif()
		set(res "[${res}]")
		return_ref(res)
	else()			
		ref_get( ${value} )
		ans(ref_value)
		if(list_to_array)
			list_new()
			ans(lst)
			ref_set(${lst} "${ref_value}")
			json_serialize( "${lst}" ${recursive_args})
			ans(serialized_value)
			return_ref(serialized_value)
		endif()

		json_escape( "${ref_value}")
		ans(ref_value)

		return_ref(ref_value)

	endif()
endfunction()




# parses simple json: only arrays, objects and double quoted strings as values and only double quoted strings as keys
# little to no error notification (be sure your json is valid)
function(json_deserialize json)
	json2("${json}")
  return_ans()
endfunction()




function(json_format_tokens result tokens)
	set(spacing "  ")
	set(level 0)
	set(indentation "")
	macro(set_indent)
		set(indentation)
		if("${level}" GREATER 0)
		math(EXPR range "${level} - 1")
		foreach(i RANGE "${range}")
			set(indentation "${indentation}${spacing}")
		endforeach()
		endif()
	endmacro()
	macro(increase_indent)
		math(EXPR level "${level} + 1")
		set_indent()
	endmacro()


	macro(decrease_indent)
		math(EXPR level "${level} - 1")
		set_indent()
	endmacro()
	set_indent()

	set(indented "${indentation}")
	foreach(token ${tokens})		
		if("${token}" STREQUAL "{")
			increase_indent()
			set(indented "${indented}{\n${indentation}")
		elseif("${token}" STREQUAL "<")
			increase_indent()
			set(indented "${indented}[\n${indentation}")
		elseif("${token}" STREQUAL ",")
			set(indented "${indented},\n${indentation}")
		elseif("${token}" STREQUAL "}")
			decrease_indent()
			set(indented "${indented}\n${indentation}}")
		elseif("${token}" STREQUAL ">")
			decrease_indent()
			set(indented "${indented}\n${indentation}]")
		elseif("${token}" STREQUAL ":")
			set(indented "${indented} : ")
		else()
			if(NOT  "${token}" MATCHES "^\".*")
				set(indented "${indented};")
			endif()

			json_escape( "${token}")
			ans(token)
			set(indented "${indented}${token}")
		endif()



	endforeach()
	return_value("${indented}")
endfunction()




# function to escape json
function(json_escape value)
	string(REGEX REPLACE "\\\\" "\\\\\\\\" value "${value}")
	string(REGEX REPLACE "\\\"" "\\\\\"" value "${value}")
	string(REGEX REPLACE "\n" "\\\\n" value "${value}")
	string(REGEX REPLACE "\r" "\\\\r" value "${value}")
	string(REGEX REPLACE "\t" "\\\\t" value "${value}")
	string(REGEX REPLACE "\\$" "\\\\$" value "${value}")	
	string(REGEX REPLACE ";" "\\\\\\\\;" value "${value}")
	return_ref(value)
endfunction()




  function(cmake_string_escape str)
    string(REPLACE "\\" "\\\\" str "${str}")
    string(REPLACE "\"" "\\\"" str "${str}")
    string(REPLACE "(" "\\(" str "${str}")
    string(REPLACE ")" "\\)" str "${str}")
    string(REPLACE "$" "\\$" str "${str}") 
    string(REPLACE "#" "\\#" str "${str}") 
    string(REPLACE "^" "\\^" str "${str}") 
    string(REPLACE "\t" "\\t" str "${str}")
    string(REPLACE ";" "\\;" str "${str}")
    string(REPLACE "\n" "\\n" str "${str}")
    string(REPLACE "\r" "\\r" str "${str}")
    string(REPLACE "\0" "\\0" str "${str}")
    string(REPLACE " " "\\ " str "${str}")
    return_ref(str)
  endfunction()





 # todo: complete
 function(map_restore_refs ref)
    map_new()
    ans(ref_ids)

    function(map_restore_find_refs cancel node)
      ref_isvalid(${node})
      ans(isref)
      map_isvalid(${node})
      ans(ismap)

      if(ismap)
        map_tryget(${node}  "$id")
        ans(id)
        if(id)
          map_set(${ref_ids} "${id}" ${node})
        endif()
      endif()
    endfunction()
    function(map_restore_restore_refs cancel node)

    endfunction()

    # find refs
    map_graphsearch(VISIT map_restore_find_refs ${ref})
    map_graphsearch(VISIT map_restore_restore_refs ${ref})

    
    #restore refs
   # map_print(${ref_ids})
   # map_print(${ref})
  endfunction()




# writes the specified values to path as a quickmap file
# path is an <unqualified file>
# returns the <qualified path> were values were written to
function(qm_write path )
  path("${path}")
  ans(path)

  qm_serialize(${ARGN})
  ans(res)
  fwrite("${path}" "${res}")
  return_ref(path)
endfunction()




# reads the qualifies and reads the specified <unqualified path>
# returns a <map>
function(qm_read path)
  path("${path}")
  ans(path)

  qm_deserialize_file("${path}")
  return_ans()
  
endfunction()






# deserializes the specified file
function(qm_deserialize_file quick_map_file)
  if(NOT EXISTS "${quick_map_file}")
    return()
  endif()
  include(${quick_map_file})
  ans(res)
  ref_get(${res})
  return_ans()
endfunction()




function(qm_print)
  qm_serialize(${ARGN})
  ans(res)

  message("${res}")
  return()
endfunction()





function(qm_serialize)
  # define callbacks for building result
  function(qm_obj_begin_indented)
   # message(PUSH_AFTER "qm_obj_begin_indented(${ARGN})")
    map_tryget(${context} indentation)
    ans(indentation)
    map_append_string(${context} qm "${indentation}map()\n")
    map_append_string(${context} indentation " ")
  endfunction()
  function(qm_obj_end_indented)
    #message(POP "qm_obj_end_indented(${ARGN})")
    map_tryget(${context} indentation)
    ans(indentation)
    string(SUBSTRING "${indentation}" 1 -1 indentation)
    map_set(${context} indentation "${indentation}")
    map_append_string(${context} qm "${indentation}end()\n")

  endfunction()

  function(qm_obj_keyvalue_begin_indented)
   # message("qm_obj_keyvalue_begin_indented(${key} ${ARGN}) ${context}")
    map_tryget(${context} indentation)
    ans(indentation)
    map_append_string(${context} qm "${indentation}key(\"${map_element_key}\")\n")
  endfunction()

  function(qm_literal_indented)
    map_tryget(${context} indentation)
    ans(indentation)
    
    cmake_string_escape("${node}")
    ans(node)
    map_append_string(${context} qm "${indentation} val(\"${node}\")\n")
    
    return()
  endfunction()


   map()
    kv(value              qm_literal_indented)
    kv(map_begin          qm_obj_begin_indented)
    kv(map_end            qm_obj_end_indented)
    kv(map_element_begin  qm_obj_keyvalue_begin_indented)
  end()
  ans(qm_cbs)
  function_import_table(${qm_cbs} qm_indented_callback)

  # function definition
  function(qm_serialize)        
    map_new()
    ans(context)
    map_set(${context} qm "#qm/1.0\nref()\n")
    #map_new()
    #ans(data)
    #map_set(${data} data "${ARGN}")
    dfs_callback(qm_indented_callback ${ARGN})
    map_tryget(${context} qm)
    ans(res)
    set(res "${res}end()\n")
    return_ref(res)  
  endfunction()
  #delegate
  qm_serialize(${ARGN})
  return_ans()
endfunction()






function(qm_deserialize quick_map_string)
  set_ans("")
  eval("${quick_map_string}")
  ans(res)
  ref_get(${res})
#  map_tryget(${res} data)
  return_ans()
endfunction()






# deserializes a csv string 
# currently expects the first line to be the column headers
# rows are separated by \n or \r\n
# every value is delimited by double quoutes ""
function(csv_deserialize csv) 
  set(args ${ARGN})
  list_extract_flag(args --headers)
  ans(first_line_headers)
  string(REPLACE "\r" "" csv "${csv}")

  string_split("${csv}" "\n")
  ans(lines)
  string(STRIP "${lines}" lines)

  set(res)
  set(headers)
  set(first true)
  set(i 0)
  foreach(line ${lines})
    map_new()
    ans(current_line)
    set(current_headers ${headers})
    while(true)
      string_take_delimited(line)
      ans(val)
      if("${line}_" STREQUAL "_")
        break()
      endif()

      string_take(line ",")
      ans(comma)
        
      if(first)
        if(first_line_headers)
          list(APPEND headers "${val}")
        else()
          list(APPEND headers ${i})            
        endif()
        math(EXPR i "${i} + 1")
      else()
        list_pop_front(current_headers)
        ans(current_header)
        map_set(${current_line} "${current_header}" "${val}")
      endif()

    endwhile()
    if(NOT first)
      list(APPEND res ${current_line})
    elseif(NOT  first_line_headers)
      list(APPEND res ${current_line})
    endif()
    if(first)        
      set(first false)
    endif()

  endforeach()
  return_ref(res)
endfunction()






  function(csv_serialize )
    set(args ${ARGN})
    message(FATAL_ERROR)

  endfunction()




function(json2_definition)
map()
 key("name")
  val("json2")
 key("phases")
 map()
  key("name")
   val("parse")
  key("function")
   val("parse_string\(/1\ /2\ /3\ /4\ /5\)")
  key("input")
   val("input_ref")
   val("def")
   val("definitions")
   val("parsers")
   val("global")
  key("output")
   val("output")
 end()
 map()
  key("name")
   val("create\ input\ ref")
  key("function")
   val("ref_setnew\(/1\)")
  key("input")
   val("input")
  key("output")
   val("input_ref")
 end()
 key("parsers")
 map()
  key("regex")
   val("parse_regex")
  key("match")
   val("parse_match")
  key("sequence")
   val("parse_sequence")
  key("any")
   val("parse_any")
  key("many")
   val("parse_many")
  key("object")
   val("parse_object")
 end()
 key("definitions")
 map()
  key("json")
  map()
   key("parser")
    val("any")
   key("any")
    val("value")
  end()
  key("value")
  map()
   key("parser")
    val("any")
   key("any")
    val("string")
    val("number")
    val("null")
    val("boolean")
    val("object")
    val("array")
  end()
  key("object")
  map()
   key("parser")
    val("object")
   key("begin")
    val("brace_open")
   key("keyvalue")
    val("keyvalue")
   key("end")
    val("brace_close")
   key("separator")
    val("comma")
  end()
  key("keyvalue")
  map()
   key("parser")
    val("sequence")
   key("sequence")
   map()
    key("key")
     val("string")
    key("colon")
     val("/colon")
    key("value")
     val("value")
   end()
  end()
  key("array")
  map()
   key("parser")
    val("many")
   key("begin")
    val("bracket_open")
   key("element")
    val("value")
   key("separator")
    val("comma")
   key("end")
    val("bracket_close")
  end()
  key("string")
  map()
   key("parser")
    val("regex")
   key("regex")
    val("\"\(\([\^\\\"]|\\\\|\(\\\\([\"tnr]\)\)\)*\)\"")
   #key("replace")
   # val("\\\\1")
   key("transform")
    val("json_string_ref_to_cmake")
   key("ignore_regex")
    val("[\ \n\r\t]+")
  end()
  key("number")
  map()
   key("parser")
    val("regex")
   key("regex")
    val("0|[1-9][0-9]*")
   key("ignore_regex")
    val("[\ \n\r\t]+")
  end()
  key("boolean")
  map()
   key("parser")
    val("regex")
   key("regex")
    val("(true|false)")
   key("ignore_regex")
    val("[\ \n\r\t]+")
  end()
  key("null")
  map()
   key("parser")
    val("regex")
   key("regex")
    val("(null)")
   key("replace")
    val("")
   key("ignore_regex")
    val("[\ \n\r\t]+")
  end()
  key("whitespace")
  map()
   key("parser")
    val("regex")
   key("regex")
    val("[\ \n\r\t]+")
  end()
  key("colon")
  map()
   key("parser")
    val("match")
   key("search")
    val(":")
   key("ignore_regex")
    val("[\ \n\r\t]+")
  end()
  key("comma")
  map()
   key("parser")
    val("match")
   key("search")
    val(",")
   key("ignore_regex")
    val("[\ \n\r\t]+")
  end()
  key("brace_open")
  map()
   key("parser")
    val("match")
   key("search")
    val("{")
   key("ignore_regex")
    val("[\ \n\r\t]+")
  end()
  key("brace_close")
  map()
   key("parser")
    val("match")
   key("search")
    val("}")
   key("ignore_regex")
    val("[\ \n\r\t]+")
  end()
  key("bracket_open")
  map()
   key("parser")
    val("match")
   key("search")
    val("[")
   key("ignore_regex")
    val("[\ \n\r\t]+")
  end()
  key("bracket_close")
  map()
   key("parser")
    val("match")
   key("search")
    val("]")
   key("ignore_regex")
    val("[\ \n\r\t]+")
  end()
 end()
end()
return_ans()
endfunction()




# creates a new xml node
# {
#   tag:'tag string'
#   //child_nodes:[xml_node, ...]
#   //parent:xml_node
#   attrs: {  }
#   value: 'string'
#   
# }
function(xml_node tag value attrs)
  obj("${attrs}")
  ans(attrs)
  map()
    kv(tag "${tag}")
    kv(value "${value}")
    kv(attrs "${attrs}")
  end()
  ans(res)
  return_ref(res)
endfunction()





  function(xml_parse_values xml tag)
    xml_parse_tags("${xml}" "${tag}")
    ans(nodes)
    set(res)
    foreach(node ${nodes})
      nav(node.value)
      ans(val)
      list(APPEND res "${val}")
    endforeach()
    return_ref(res)
  endfunction()




## naive way of parsing xml tags
## returns a list of all matched xml nodes
## warning: does not supported nested nodes of same name!! and no tag whithout closing tag: <test/>
## {
##  value:"content",
##  attrs:{
##    key:"val",
##    key:"val",
##    ...
##  }
## }
function(xml_parse_tags xml tag)
  set(regex_str "\\\"([^\\\"]*)\\\"")
  set(regex_attrs "([a-zA-Z_-][a-zA-Z0-9_-]*) *= *${regex_str}")
  set(regex "< *${tag}([^>]*)>(.*)</ *${tag} *>")
  string(REGEX MATCHALL "${regex}"  output "${xml}")

  set(res)
  foreach(match ${output})
    string(REGEX REPLACE "${regex}" "\\1" attrs "${match}") 
    string(REGEX REPLACE "${regex}" "\\2" match "${match}") 


    map()
      kv(tag "${tag}")
      kv(value "${match}")    
      map(attrs)
        string(REGEX MATCHALL "${regex_attrs}" attrs "${attrs}")
        foreach(attr ${attrs})
          string(REGEX REPLACE "${regex_attrs}" "\\1" key "${attr}")
          string(REGEX REPLACE "${regex_attrs}" "\\2" val "${attr}")
          kv("${key}" "${val}")
        endforeach()
      end()
    end()
    ans(t)
    list(APPEND res ${t})

  endforeach()

  return_ref(res)

endfunction()





  function(xml_parse_attrs xml tag attr)
    xml_parse_tags("${xml}" "${tag}")
    ans(nodes)
    set(res)
    foreach(node ${nodes})
      map_tryget(${node} attrs)
      ans(attrs)
      map_tryget("${attrs}" "${attr}")
      ans(it)
      list(APPEND res "${it}")
    endforeach()
    return_ref(res)
  endfunction()




# returns the value at the specified path (path is specified as path fragment list)
# e.g. map = {a:{b:{c:{d:{e:3}}}}}
# map_path_get(${map} a b c d e)
# returns 3
# this function is somewhat faster than map_navigate()
function(map_path_get map)
  set(args ${ARGN})
  set(current "${map}")
  foreach(arg ${args}) 
    if(NOT current)
      return()
   endif()
   map_tryget("${current}" "${arg}")
   ans(current)
  endforeach()
  return_ref(current)
endfunction()






  ## unpacks the specified reference to a map
  ## let a map be stored in the var 'themap'
  ## let it have the key/values a/1 b/2 c/3
  ## map_unpack(themap) will create the variables
  ## ${themap.a} contains 1
  ## ${themap.b} contains 2
  ## ${themap.c} contains 3
  function(map_unpack __ref)
    map_iterator(${${__ref}})
    ans(it)
    while(true)
      map_iterator_break(it)
      set("${__ref}.${it.key}" ${it.value} PARENT_SCOPE)
    endwhile()
  endfunction()






  function(map_to_valuelist map)
    set(keys ${ARGN})
    list_extract_flag(keys --all)
    ans(all)
    if(all)
      map_keys(${map})
      ans(keys)
    endif()
    set(result)

    foreach(key ${keys})
      map_tryget(${map} "${key}")
      ans(value)
      list(APPEND result "${value}")
    endforeach()
    return_ref(result)
  endfunction()





# returns a copy of map returning only the whitelisted keys
function(map_pick map)
    map_new()
    ans(res)
    foreach(key ${ARGN})
      obj_get(${map} "${key}")
      ans(val)

      map_set("${res}" "${key}" "${val}")
    endforeach()
    return("${res}")
endfunction()






# sets all undefined properties of map to the default value
function(map_defaults map defaults)
  obj("${defaults}")
  ans(defaults)
  if(NOT defaults)
    message(FATAL_ERROR "No defaults specified")
  endif()

  if(NOT map)
    map_new()
    ans(map)
  endif()

  map_keys("${map}")
  ans(keys)

  map_keys("${defaults}")
  ans(default_keys)


  if(default_keys AND keys)
    list(REMOVE_ITEM default_keys ${keys})
  endif()
  foreach(key ${default_keys})
    map_tryget("${defaults}" "${key}")
    ans(val)
    map_set("${map}" "${key}" "${val}")
  endforeach()
  return_ref(map)
endfunction()




# returns all values of the map which are passed as ARNG
function(map_values this)
  set(args ${ARGN})
  if(NOT args)
    map_keys(${this})
    ans(args)
  endif()
  set(res)
	foreach(arg ${args})
		map_get(${this}  ${arg})
    ans(val)
		list(APPEND res ${val})	
	endforeach()
  return_ref(res)
endfunction()




# ensures that the specified vars are a map
# parsing structured data if necessary
  macro(map_ensure)
    foreach(__map_ensure_arg ${ARGN})
      obj("${${__map_ensure_arg}}")
      ans("${__map_ensure_arg}")
    endforeach()
  endmacro()




## renames a key in the specified map
function(map_rename map key_old key_new)
  map_get("${map}" "${key_old}")
  ans(value)
  map_remove("${map}" "${key_old}")
  map_set("${map}" "${key_new}" "${value}")
endfunction()





# todo implement

function(map_path_set map path value)
  message(FATAL_ERROR "not implemented")
  if(NOT map)
    map_new()
    ans(map)
  endif()

  set(current "${map}")

  foreach(arg ${path})
    map_tryget("${current}" "${arg}")
    ans(current) 

  endforeach()

endfunction()







# returns a copy of map with key values inverted
# only works correctly for bijective maps
function(map_invert map)
  map_keys("${map}")
  ans(keys)
  map_new()
  ans(inverted_map)
  foreach(key ${keys})
    map_tryget("${map}" "${key}")
    ans(val)
    map_set("${inverted_map}" "${val}" "${key}")
  endforeach()
  return_ref(inverted_map)
endfunction()




# converts a map to a key value list 
function(map_to_keyvaluelist map)
  map_keys(${map})
  ans(keys)
  set(kvl)
  foreach(key ${keys})
    map_get("${map}" "${key}")
    ans(val)
    list(APPEND kvl "${key}" "${val}")
  endforeach()
  return_ref(kvl)
endfunction()






  ## files non existing or null values of lhs with values of rhs
  function(map_fill lhs rhs)
    map_ensure(lhs rhs)
    map_iterator(${rhs})
    ans(it)
    while(true)
      map_iterator_break(it)
    
      map_tryget(${lhs} "${it.key}")
      ans(lvalue)

      if("${lvalue}_" STREQUAL "_")
        map_set(${lhs} "${it.key}" "${it.value}")
      endif()
    endwhile()
    return_ref(lhs)
  endfunction()




# returns true if map's properties match all properties of attrs
function(map_match_properties map attrs)
  map_keys("${attrs}")
  ans(attr_keys)
  foreach(key ${attr_keys})

    map_tryget("${map}" "${key}")
    ans(val)
    map_tryget("${attrs}" "${key}")
    ans(pred)
   # message("matching ${map}'s ${key} '${val}' with ${pred}")
    if(NOT "${val}" MATCHES "${pred}")
      return(false)
    endif()
  endforeach()
  return(true)
endfunction()






## captures the listed variables in the map
function(map_capture map )
  set(__map_capture_args ${ARGN})
  list_extract_flag(__map_capture_args --reassign)
  ans(__reassign)
  list_extract_flag(__map_capture_args --notnull)
  ans(__not_null)
  foreach(__map_capture_arg ${ARGN})
    
    if(__reassign AND "${__map_capture_arg}" MATCHES "(.+)[:=](.+)")
      set(__map_capture_arg_key ${CMAKE_MATCH_1})
      set(__map_capture_arg ${CMAKE_MATCH_2})
    else()
      set(__map_capture_arg_key "${__map_capture_arg}")
    endif()
   # print_vars(__map_capture_arg __map_capture_arg_key)
    if(NOT __not_null OR NOT "${${__map_capture_arg}}_" STREQUAL "_")
      map_set(${map} "${__map_capture_arg_key}" "${${__map_capture_arg}}")
    endif()
  endforeach()
endfunction()








# removes all properties from map
function(map_clear map)
  map_keys("${map}")
  ans(keys)
  foreach(key ${keys})
    map_remove("${map}" "${key}")
  endforeach()
  return()
endfunction()





  ## returns the length of the specified property
  function(map_property_length map prop)
    map_tryget("${map}" "${prop}")
    ans(val)
    list(LENGTH val len)
    return_ref(len)
  endfunction()






function(map_pop_front map prop)
  map_tryget("${map}" "${prop}")
  ans(lst)
  list_pop_front(lst)
  ans(res)
  map_set("${map}" "${prop}" ${lst})
  return_ref(res)
endfunction()




## function which generates a map 
## out of the passed args 
## or just returns the arg if it is already valid
function(mm)
  
  set(args ${ARGN})
  # assignment
  list(LENGTH args len)
  if("${len}" GREATER 2)
    list(GET args 1 equal)
    list(GET args 0 target)
    if("${equal}" STREQUAL = AND "${target}" MATCHES "[a-zA-Z0-9_\\-]")
      list(REMOVE_AT args 0 )
      list(REMOVE_AT args 0 )
      mm(${args})
      ans(res)
      set("${target}" "${res}" PARENT_SCOPE)
      return_ref(res)
    endif()
  endif()



  data(${ARGN})
  return_ans()
endfunction()






# returns a copy of map without the specified keys (argn)
function(map_omit map)
  map_keys("${map}")
  ans(keys)
  if(ARGN)
    list(REMOVE_ITEM keys ${ARGN})
  endif()
  map_pick("${map}" ${keys})
  return_ans()
endfunction()




function(test)
  new()
  ans(obj)
  obj_set(${obj} "test1" "val1")
  obj_set(${obj} "test2" "val2")
  obj_set(${obj} "test3" "val3")


  obj_pick("${obj}" test1 test3)
  ans(res)
  assert(DEREF {res.test1} STREQUAL "val1")
  assert(DEREF {res.test3} STREQUAL "val3")

  obj_pick("${obj}" test4)
  ans(res)
  assert(res)
  assert(DEREF "_{res.test4}" STREQUAL "_")


endfunction()




# adds the keyvalues list to the map (if not map specified created one)
function(map_from_keyvaluelist map)
  if(NOT map)
    map_new()
    ans(map)
  endif()
  set(args ${ARGN})
  while(true)
    list_pop_front(args)
    ans(key)
    list_pop_front(args)
    ans(val)
    if(NOT key)
      break()
    endif()
    map_set("${map}" "${key}" "${val}")
  endwhile()
  return_ref(map)
endfunction()






# returns a list key;value;key;value;...
# only works if key and value are not lists (ie do not contain ;)
function(map_pairs map)
  map_keys("${map}")
  ans(keys)
  set(pairs)
  foreach(key ${keys})
    map_tryget("${map}" "${key}")
    ans(val)
    list(APPEND pairs "${key}")
    list(APPEND pairs "${val}")
  endforeach()
  return_ref(pairs)
endfunction()






  ## checks if all fields specified in actual rhs are equal to the values in expected lhs
  ## recursively checks submaps
  function(map_match lhs rhs)
    if("${lhs}_" STREQUAL "${rhs}_")
      return(true)
    endif()


    list(LENGTH lhs lhs_length)
    list(LENGTH rhs rhs_length)

    if(NOT "${lhs_length}" EQUAL "${rhs_length}")
      return(false)
    endif()
  
    if(${lhs_length} GREATER 1)
      while(true)
        list(LENGTH lhs len)
        if(NOT len)
          break()
        endif()

        list_pop_back(lhs)
        ans(lhs_value)
        list_pop_back(rhs)
        ans(rhs_value)
        map_match("${lhs_value}" "${rhs_value}")
        ans(is_match)
        if(NOT is_match)
          return(false)
        endif()
      endwhile()
      return(true)
    endif() 

    map_isvalid("${rhs}")
    ans(rhs_ismap)

    map_isvalid("${lhs}")
    ans(lhs_ismap)

  
    if(NOT lhs_ismap OR NOT rhs_ismap)
      return(false)
    endif()


    map_iterator(${rhs})
    ans(it)

    while(true)
      map_iterator_break(it)

      map_tryget("${lhs}" "${it.key}")
      ans(lhs_value)

      map_match("${lhs_value}" "${it.value}")
      ans(values_match)

      if(NOT values_match)
        return(false)
      endif()

    endwhile()

    return(true)

  endfunction()




function(map_edit)
	# function for editing a map by console commands
	set(options
		--sort
		--insert
		--reverse
		--remove-duplicates
		--set
		--append
		--remove
		--reorder
		--print
	)

	cmake_parse_arguments("" "${options}" "" "" ${ARGN})
	
	list(GET _UNPARSED_ARGUMENTS 0 navigation_expression)
	list(REMOVE_AT _UNPARSED_ARGUMENTS 0)
	set(arg ${_UNPARSED_ARGUMENTS})


	map_transform( "${arg}")
	ans(arg)
	map_navigate(value "${navigation_expression}")
	list_isvalid("${value}" )
	ans(islist)
	set(result_list)
	if(islist)
		set(result_list "${value}")
		ref_get(${value} )
		ans(value)
	endif()


	if(_--remove)
		if(NOT arg)
			set(value )
		else()
			list(REMOVE_ITEM value "${arg}")
		endif()
	elseif(_--sort)
	elseif(_--reorder)

	elseif(_--insert)
		list(INSERT value "${arg}")
	elseif(_--reverse)
	elseif(_--remove-duplicates)
	elseif(_--set )
		set(value "${arg}")
	elseif(_--append)
		set(value "${value}" "${arg}")
	else()
		if(_--print)			
			ref_print(${value})
		endif()
		return()
	endif()



	# modifiers
	if(_--remove-duplicates)
		list(REMOVE_DUPLICATES value)
	endif()

	if(_--sort)
		list(SORT value)
	endif()

	if(_--reverse)
		list(REVERSE value)
	endif()
	

	list(LENGTH value len)
	if(${len} GREATER 1)
		if(NOT result_list)
			list_new()
			ans(result_list)
		endif()
		ref_set(${result_list} "${value}")	
		set(value ${result_list})
	endif()
	map_navigate_set("${navigation_expression}" "${value}")
	if(_--print)
		ref_print("${value}")
	endif()
endfunction()





function(map_peek_front map prop)
  map_tryget("${map}" "${prop}")
  ans(lst)
  list_peek_front(lst)
  return_ans()
endfunction()





# returns true if map has any of the keys
# specified as varargs
function(map_has_any map)
  foreach(key ${ARGN})
    map_has("${map}" "${key}")
    ans(has_key)
    if(has_key)
      return(true)
    endif()
  endforeach()
  return(false)

endfunction()




  ## returns the key at the specified position
  function(map_key_at map idx)
    map_keys(${map})
    ans(keys)
    list_normalize_index(keys ${idx})
    ans(idx)
    list_get(keys ${idx})
    ans(key)
    return_ref(key)
  endfunction()









# returns all possible paths for the map
# (currently crashing on cycles cycles)
# todo: implement
function(map_all_paths)
  message(FATAL_ERROR "map_all_paths is not implemented yet")

  function(_map_all_paths event)
    if("${event}" STREQUAL "map_element_begin")
      ref_get(${current_path})
      ans(current_path)
      set(cu)
    endif()
    if("${event}" STREQUAL "value")
      ref_new(${})
    endif()
  endfunction()

  ref_new()
  ans(current_path)
  ref_new()
  ans(path_list)

  dfs_callback(_map_all_paths ${ARGN})
endfunction()




## captures a new map from the given variables
## example
## set(a 1)
## set(b 2)
## set(c 3)
## map_capture_new(a b c)
## ans(res)
## json_print(${res})
## --> 
## {
##   "a":1,
##   "b":2,
##   "c":3 
## }
function(map_capture_new)
  map_new()
  ans(__map_capture_new_map)
  map_capture(${__map_capture_new_map} ${ARGN})
  return(${__map_capture_new_map})
endfunction()





# returns true if map has all keys specified
#as varargs
function(map_has_all map)

  foreach(key ${ARGN})
    map_has("${map}" "${key}")
    ans(has_key)
    if(NOT has_key)
      return(false)
    endif()
  endforeach()
  return(true)

endfunction()






macro(map_promote __map_promote_map)
  # garbled names help free from variable collisions
  map_keys(${__map_promote_map} )
  ans(__map_promote_keys)
  foreach(__map_promote_key ${__map_promote_keys})
    map_get(${__map_promote_map}  ${__map_promote_key})
    ans(__map_promote_value)
    set("${__map_promote_key}" "${__map_promote_value}" PARENT_SCOPE)
  endforeach()
endmacro()





  function(map_isempty map)
    map_keys(${map})
    ans(keys)
    list(LENGTH keys len)
    if(len)
      return(false)
    else()
      return(true)
    endif()
  endfunction()






  ## overwrites all values of lhs with rhs
  function(map_overwrite lhs rhs)
    obj("${lhs}")
    ans(lhs)
    obj("${rhs}")
    ans(rhs)

    map_iterator("${rhs}")
    ans(it)
    while(true)
      map_iterator_break(it)
      map_set("${lhs}" "${it.key}" "${it.value}")
    endwhile()
    return(${lhs})
  endfunction()





# returns a map with all properties except those matched by any of the specified regexes
function(map_omit_regex map)
  set(regexes ${ARGN})
  map_keys("${map}")
  ans(keys)

  foreach(regex ${regexes})
    foreach(key ${keys})
        if("${key}" MATCHES "${regex}")
          list_remove(keys "${key}")
        endif()
    endforeach()
  endforeach()


  map_pick("${map}" ${keys})

  return_ans()


endfunction()





# returns a function which returns true of all 
function(map_matches attrs)
  obj("${attrs}")
  ans(attrs)
  curry(map_match_properties(/1 ${attrs}))
  return_ans()
endfunction()








  ## returns the value at idx
  function(map_at map idx)
    map_key_at(${map} "${idx}")
    ans(key)
    map_tryget(${map} "${key}")
    return_ans()
  endfunction()






function(map_pop_back map prop)
  map_tryget("${map}" "${prop}")
  ans(lst)
  list_pop_back(lst)
  ans(res)
  map_set("${map}" "${prop}" ${lst})
  return_ref(res) 
endfunction()




# copies the values of the source map into the target map by assignment
# (shallow copy)
function(map_copy_shallow target source)
  map_keys("${source}")
  ans(keys)

  foreach(key ${keys})
    map_tryget("${source}" "${key}")
    ans(val)
    map_set("${target}" "${key}" "${val}")
  endforeach()
  return()
endfunction()





function(map_peek_back map prop)
  map_tryget("${map}" "${prop}")
  ans(lst)
  list_peek_back(lst)
  return_ans()
endfunction()





# returns a map containing all properties whose keys were matched by any of the specified regexes
function(map_pick_regex map)
  set(regexes ${ARGN})
  map_keys("${map}")
  ans(keys)
  set(pick_keys)
  foreach(regex ${regexex})
    foreach(key ${keys})
      if("${key}" MATCHES "${regex}")
        list(APPEND pick_keys "${key}")
      endforeach()
    endforeach()
  endforeach()
  list(REMOVE_DUPLICATES pick_keys)
  map_pick("${map}" ${pick_keys})
  return_ans()
endfunction()







function(map_push_back map prop)
  map_tryget("${map}" "${prop}")
  ans(lst)
  list_push_back(lst ${ARGN})
  map_set("${map}" "${prop}" ${lst})
  return_ref(lst)
endfunction()




function(map_extract navigation_expressions)
  cmake_parse_arguments("" "REQUIRE" "" "" ${ARGN})
  set(args ${_UNPARSED_ARGUMENTS})
  foreach(navigation_expression ${navigation_expressions})
    map_navigate(res "${navigation_expression}")
    list_pop_front( args)
    ans(current)
    if(_REQUIRE AND NOT res)
      message(FATAL_ERROR "map_extract failed: requires ${navigation_expression}")
    endif()

    if(current)
      set(${current} ${res} PARENT_SCOPE)
    else()
      if(NOT _REQUIRE)
       break()
      endif()
    endif()
  endforeach()
  foreach(arg ${args})
    set(${arg} PARENT_SCOPE)  
  endforeach()
  
endfunction()





function(map_push_front map prop)
  map_tryget("${map}" "${prop}")
  ans(lst)
  list_push_front(lst ${ARGN})
  ans(res)
  map_set("${map}" "${prop}" ${lst})
  return_ref(res)
endfunction()







# matches the object list 
function(list_match __list_match_lst )
  map_matches("${ARGN}")
  ans(predicate)
  list_where("${__list_match_lst}" "${predicate}")
  return_ans()
endfunction()






function(cmake_string_to_json str)
  string(REPLACE "\\" "\\\\" str "${str}")


  string(REPLACE "\"" "\\\"" str "${str}")
  string(REPLACE "\n" "\\n" str "${str}")
  string(REPLACE "\t" "\\t" str "${str}")
  string(REPLACE "\t" "\\t" str "${str}")
  string(REPLACE "\r" "\\r" str "${str}")
  string(ASCII 8 bs)
  string(REPLACE "${bs}" "\\b" str "${str}")
  string(ASCII 12 ff)
  string(REPLACE "${ff}" "\\f" str "${str}")
  string(REPLACE ";" "\\\\;" str "${str}")
  set(str "\"${str}\"")
  return_ref(str)
endfunction()






  function(query_select __lst input_callback)
    set(args ${ARGN})
    list_extract_flag(args --index)
    ans(index)
    set(i 0)
    list(LENGTH ${__lst} len)

    message_indent_push(+2)
    foreach(item ${${__lst}})
      message("${i}: ${item}") 
      math(EXPR i "${i} + 1")
    endforeach()
    message_indent_pop()
    while(true)
      echo_append("> ")
      call("${input_callback}"())
      ans(selected_index)
    
      string_isnumeric("${selected_index}")
      ans(isnumeric)
      if(isnumeric)
        if("${selected_index}" GREATER 0 AND ${selected_index} LESS ${len})
          break()
        else()
          message_indent("please enter a positive number < ${len}")
        endif()
      else()
        list(FIND ${__lst} "${selected_index}" selected_index)
        if(NOT "${selected_index}_" STREQUAL "_")
          break()
        endif()
        message_indent("please enter a number")
      endif()
    endwhile()
    if(index)
      return(${selected_index})
    endif()
    list(GET ${__lst} ${selected_index} selected_value)
    return_ref(selected_value)
  endfunction()




## returns an info object for the specified svn url
## {
##    path:"path",
##    revision:"revision",
##    kind:"kind",
##    url:"url",
##    root:"root",
##    uuid:"uuid",
## }
## todo: cached?
function(svn_info uri)
    svn_uri("${uri}")
    ans(uri)


    svn(info ${uri} --result --xml ${ARGN})
    ans(res)
    map_tryget(${res} result)
    ans(error)
    if(error)
      return()
    endif()

    map_tryget(${res} output)
    ans(xml)

    xml_parse_attrs("${xml}" entry path)    
    ans(path)
    xml_parse_attrs("${xml}" entry revision)    
    ans(revision)
    xml_parse_attrs("${xml}" entry kind)    
    ans(kind)
    xml_parse_values("${xml}" url)
    ans(url)
    xml_parse_values("${xml}" root)
    ans(root)
    xml_parse_values("${xml}" relative-url)
    ans(relative_url)

    string(REGEX REPLACE "^\\^/" "" relative_url "${relative_url}")

    xml_parse_values("${xml}" uuid)
    ans(uuid)
    map()
      var(path revision kind url root uuid relative_url)
    end()
    ans(res)
    return_ref(res)
endfunction()




## svn_cached_checkout()
function(svn_cached_checkout uri)
  set(args ${ARGN})
  path_qualify(target_dir)

  list_extract_flag(args --refresh)
  ans(refresh)
  
  list_extract_flag(args --readonly)
  ans(readonly)


  list_extract_labelled_keyvalue(args --revision)
  ans(revision)
  list_extract_labelled_keyvalue(args --branch)
  ans(branch)
  list_extract_labelled_keyvalue(args --tag)
  ans(tag)

  list_pop_front(args)
  ans(target_dir)
  path_qualify(target_dir)

  
  svn_uri_analyze(${uri} ${revision} ${branch} ${tag})
  ans(svn_uri)

  map_import_properties(${svn_uri} base_uri ref_type ref revision relative_uri)

  if(NOT revision)
    set(revision HEAD)
  endif()


  if("${ref_type}" STREQUAL "branch")
    set(ref_type branches)
  elseif("${ref_type}" STREQUAL "tag")
    set(ref_type tags)
  endif()
  
  oocmake_config(cache_dir)
  ans(cache_dir)

  string(MD5 cache_key "${base_uri}@${revision}@${ref_type}@${ref}")
  set(cached_path "${cache_dir}/svn_cache/${cache_key}")
  
  if(EXISTS "${cached_path}" AND NOT refresh)
    if(readonly)
      return_ref(cached_path)
    else()
      cp_dir("${cached_path}" "${target_dir}")
      return_ref(target_dir)
    endif()
  endif()

  set(checkout_uri "${base_uri}/${ref_type}/${ref}@${revision}")
  svn_remote_exists("${checkout_uri}")
  ans(remote_exists)
  
  if(NOT remote_exists)
    return()
  endif()


  if(EXISTS "${cached_path}")
    rm("${cached_path}")
  endif()
  mkdir("${cached_path}")


  svn(checkout "${checkout_uri}" "${cached_path}" --non-interactive  --return-code)
  ans(error)

  if(error)
    rm("${cached_path}")
    return()
  endif()

  if(readonly)
    return_ref(cached_path)
  else()
    cp_dir("${cached_path}" "${target_dir}")
    return_ref(target_dir)
  endif()
endfunction()






  ## svn_uri_analyze(<input:<?uri>> [--revision <rev>] [--branch <branch>] [--tag <tag>])-> 
  ## {
  ##   input: <string>
  ##   uri: <uri string>
  ##   base_uri: <uri string>
  ##   relative_uri: <path>
  ##   ref_type: "branch"|"tag"|"trunk"
  ##   ref: <string>
  ##   revision: <rev>
  ## }
  ##
  ## 
  function(svn_uri_analyze input)
    set(args ${ARGN})

    list_extract_labelled_value(args --revision)
    ans(args_revision)
    list_extract_labelled_value(args --branch)
    ans(args_branch)
    list_extract_labelled_value(args --tag)
    ans(args_tag)

    uri("${input}")
    ans(uri)


    assign(params_revision = uri.params.rev)
    assign(params_branch = uri.params.branch)
    assign(params_tag = uri.params.tag)

    set(trunk_dir trunk)
    set(tags_dir tags)
    set(branches_dir branches)

    uri_format(${uri} --no-query)
    ans(formatted_uri)

    set(uri_revision)
    if("${formatted_uri}" MATCHES "@(([1-9][0-9]*)|HEAD)(\\?|$)")
      set(uri_revision "${CMAKE_MATCH_1}")
      string(REGEX REPLACE "@${uri_revision}" "" formatted_uri "${formatted_uri}")
    endif()

    set(CMAKE_MATCH_3)
    set(uri_ref)
    set(base_uri "${formatted_uri}")
    set(uri_tag)
    set(uri_branch)
    set(uri_rel_path)
    set(uri_ref_type)
    set(ref_type)
    set(ref)
    if("${formatted_uri}" MATCHES "(.*)/(${trunk_dir}|${tags_dir}|${branches_dir})(/|$)")
      set(base_uri "${CMAKE_MATCH_1}")
      set(uri_ref_type "${CMAKE_MATCH_2}")

      set(uri_rel_path "${formatted_uri}")
      string_take(uri_rel_path "${base_uri}/${uri_ref_type}")
      string_take(uri_rel_path "/")

      if(uri_ref_type STREQUAL "${tags_dir}" OR uri_ref_type STREQUAL "${branches_dir}")
        string_take_regex(uri_rel_path "[^/]+")
        ans(uri_ref)
      endif()
      
      if(uri_ref_type STREQUAL "${branches_dir}")
        set(uri_branch ${uri_ref})
      endif()
      if(uri_ref_type STREQUAL "${tags_dir}")
        set(uri_tag "${uri_ref}")
      endif()      

    endif()



    set(revision ${args_revision} ${params_revision} ${uri_revision})
    list_peek_front(revision)
    ans(revision)



    if(uri_ref_type STREQUAL "trunk")
      set(ref_type trunk)
      set(ref trunk)
    endif()

    if(uri_ref_type STREQUAL "branches")
      set(ref_type branch)
      set(ref ${uri_ref})
    endif()

    if(uri_ref_type STREQUAL "tags")
      set(ref_type tag)
      set(ref ${uri_ref})
    endif()

    
    if(args_branch)
      set(ref_type branch)
      set(ref ${args_branch})
    endif()

    if(args_tag)
      set(ref_type tag)
      set(ref ${args_tag})
    endif()

    if("${ref_type}_" STREQUAL "_")
      set(ref_type trunk)
      set(ref)
    endif()


    map_new()
    ans(result)
    map_set(${result} input ${input})
    map_set(${result} uri ${formatted_uri} )
    map_set(${result} base_uri "${base_uri}")
    map_set(${result} relative_uri "${uri_rel_path}")
    map_set(${result} ref_type "${ref_type}")
    map_set(${result} ref "${ref}")
    map_set(${result} revision "${revision}")

    return(${result})
  endfunction()




## returns the revision for the specified svn uri
function(svn_get_revision)
  svn_info("${ARGN}")
  ans(res)
  nav(res.revision)
  return_ans()
endfunction()




## returns the svn_uri for the given ARGN
## if its empty emtpy is returned
## if it exists it is returned
## if it exists after qualification the qualifed path is returned
## else it is retunred
function(svn_uri)

  set(uri ${ARGN})
  if(NOT uri)
    return()
  endif()
  if(EXISTS "${uri}")
    return("${uri}")
  endif()
  path("${uri}")
  ans(uri_path)
  if(EXISTS "${uri_path}")
    return_ref(uri_path)
  endif()
  return_ref(uri)
endfunction()








  function(svn_uri_format_package_uri svn_uri)
    map_import_properties(${svn_uri} base_uri revision ref ref_type)

    string(REGEX REPLACE "^svnscm\\+" "" base_uri "${base_uri}")

    if("${ref_type}" STREQUAL "branch")
      set(ref_type branches)
    elseif("${ref_type}" STREQUAL "tag")
      set(ref_type tags)
    endif()

    if(revision STREQUAL "HEAD")
      set(revision)
    endif() 


    set(params)
    if(NOT ref_type STREQUAL "trunk" OR revision)
      map_new()
      ans(params)
      if(NOT revision STREQUAL "")
        map_set(${params} rev "${revision}")
      endif()
      if(ref_type STREQUAL trunk)
      elseif("${ref_type}" STREQUAL "branch")
        map_set(${params} branch "${ref}")
      elseif("${ref_type}" STREQUAL "tag")
        map_set(${params} branch "${ref}")
      endif()
      uri_params_serialize(${params})
      ans(query)
      set(query "?${query}")
    endif()

    set(result "${base_uri}${query}")


    return_ref(result)


  endfunction()




## returns true if a svn repository exists at the specified location
  function(svn_remote_exists uri)
    svn(ls "${uri}" --depth empty --non-interactive --return-code)
    ans(error)
    if(error)
      return(false)
    endif()
    return(true)
  endfunction()





  function(svn_uri_format_ref svn_uri)
    map_import_properties(${svn_uri} base_uri revision ref ref_type)

    string(REGEX REPLACE "^svnscm\\+" "" base_uri "${base_uri}")
    if(NOT revision)
      set(revision HEAD)
    endif()

    if("${ref_type}" STREQUAL "branch")
      set(ref_type branches)
    elseif("${ref_type}" STREQUAL "tag")
      set(ref_type tags)
    endif()
    
    set(checkout_uri "${base_uri}/${ref_type}/${ref}@${revision}")
    return_ref(checkout_uri)

  endfunction()





# convenience function for accessing subversion
# use cd() to navigate to working directory
# usage is same as svn command line client
# syntax differs: svn arg1 arg2 ... -> svn(arg1 arg2 ...)
# also see wrap_executable for usage
# add a --result flag to get a object containing return code, output
# input args etc.
# add --return-code flag to get the return code of the commmand
# by default fails if return code is not 0 else returns  stdout/stderr
function(svn)
  find_package(Subversion)
  if(NOT SUBVERSION_FOUND)
    message(FATAL_ERROR "subversion is not installed")
  endif()
  # to prohibit non utf 8 decode errors
  set(ENV{LANG} C)
  set(ENV{LC_MESSAGES} C)
  
  wrap_executable(svn "${Subversion_SVN_EXECUTABLE}")
  
  svn(${ARGN})
  return_ans()
endfunction()





## returns the git base dir (the directory in which .git is located)
function(git_base_dir)  
  git_dir("${ARGN}")
  ans(res)
  path_component("${res}" --parent-dir)
  ans(res)
  return_ref(res)
endfunction()




function(git)
  find_package(Git)
  if(NOT GIT_FOUND)
    message(FATAL_ERROR "missing git")
  endif()

  wrap_executable(git "${GIT_EXECUTABLE}")
  git(${ARGN})
  return_ans()


endfunction()  







# reads a single file from a git repository@branch using the 
# repository relative path ${path}. returns the contents of the file
function(git_read_single_file repository branch path )
  file_tempdir()
  ans(tmp_dir)
  mkdir("${tmp_dir}")

  set(branch_arg)
  if(branch)
    set(branch_arg --branch "${branch}") 
  endif()

  git(clone --no-checkout ${branch_arg} --depth 1 "${repository}" "${tmp_dir}" --return-code)
  ans(error)

  if(error)
    rm(-r "${tmp_dir}")
    popd()
    return()
  endif()

  if(NOT branch)
    set(branch HEAD)
  endif()


  pushd("${tmp_dir}")
  git(show --format=raw "${branch}:${path}" --result)
  ans(result)

  map_tryget(${result} output)
  ans(res)
  map_tryget(${result} result)  
  ans(error)
  popd()


  popd()
  rm(-r "${tmp_dir}")

  
  if(error)
    return()
  endif()
  

  return_ref(res)
  
endfunction()




# registers a git hook
function(git_register_hook hook_name)
  git_directory()
  ans(git_dir)


endfunction()


function(git_local_hooks)
  set(hooks
    pre-commit
    post-commit
    prepare-commit-msg
    commit-msg
    pre-rebase
    post-checkout

    )
  return_ref(hooks)

endfunction()





## returns the git uri for the given ARGN
## if its empty emtpy is returned
## if it exists it is returned
## if it exists after qualification the qualifed path is returned
## else it is retunred
function(git_uri)

  set(uri ${ARGN})
  if(NOT uri)
    return()
  endif()
  if(EXISTS "${uri}")
    return("${uri}")
  endif()
  path("${uri}")
  ans(uri_path)
  if(EXISTS "${uri_path}")
    return_ref(uri_path)
  endif()
  return_ref(uri)
endfunction()








    function(git_cached_clone target_dir remote_uri git_ref)
      set(args ${ARGN})
      list_extract_flag(args --readonly)
      ans(readonly)

      list_extract_labelled_value(args --file)
      ans(file)

      list_extract_labelled_value(args --read)
      ans(read)


      path_qualify(target_dir)

      oocmake_config(cache_dir)
      ans(cache_dir)

      string(MD5 cache_key "${remote_uri}" )

      set(repo_cache_dir "${cache_dir}/git_cache/${cache_key}")

      if(NOT EXISTS "${repo_cache_dir}")
        git(clone --mirror "${remote_uri}" "${repo_cache_dir}" --return-code)
        ans(error)
        if(error)
          rm("${repo_cache_dir}")
          message(FATAL_ERROR "could not clone ${remote_uri}")
        endif()

      endif()


      pushd("${repo_cache_dir}")
        set(ref "${git_ref}")
        if(NOT ref)
          set(ref "HEAD")
        endif()
        if(read)
          git(show "${ref}:${read}")
          return_ans()
        endif()

        if(file)
          git(show "${ref}:${file}")
          ans(res)
          set(target_path "${target_dir}/${file}")
          fwrite("${target_path}t" "${res}")
          return(target_path)
        endif()

        git(clone --reference "${repo_cache_dir}" "${remote_uri}" "${target_dir}")
        pushd("${target_dir}")
          git(checkout "${git_ref}")
          git(submodule init)
          git(submodule update)
        popd()
      popd()

      return_ref(target_dir)      

    endfunction()





# checks wether the uri is a remote git repository
function(git_remote_exists uri)
  git_uri("${uri}")
  ans(uri)

  git(ls-remote "${uri}" --return-code)
  ans(res)
  
  if("${res}" EQUAL 0)
    return(true)
  endif()
  return(false)
endfunction()





# checks the remote uri if a ref exists ref_type can be * to match any
# else it can be tags heads or HEAD
# returns the corresponding ref object
function(git_remote_ref uri ref_name ref_type)
  git_remote_refs( ${uri})
  ans(refs)
  foreach(current_ref ${refs})
    map_navigate(name "current_ref.name")
    if("${name}" STREQUAL "${ref_name}")
      if(ref_type STREQUAL "*")
        return(${current_ref})
      else()
        map_navigate(type "current_ref.type")
        if(${type} STREQUAL "${ref_type}")
          return("${current_ref}")
        endif()
        return()
      endif()
    endif()
  endforeach()
  return()
endfunction()








# returns the git directory for pwd or specified path
function(git_dir)
  set(path ${ARGN})
  path("${path}")
  ans(path)
  message("${path}")

  pushd("${path}")
  git(rev-parse --show-toplevel)
  ans(res)
  message("${res}")
  
  popd()
  string(STRIP "${res}" res)
  set(res "${res}/.git")
  message("${res}")
  return_ref(res)
endfunction()






# checks the remote uri if a ref exists ref_type can be * to match any
# else it can be tags heads or HEAD
function(git_remote_has_ref uri ref_name ref_type)
  git_remote_ref("${uri}" "${ref_name}" "${ref_type}")
  ans(res)
  if(res)
    return(true)
  else()
    return(false)
  endif()

endfunction()







# parses a git ref and retruns a map with the fields type and name
function(git_ref_parse  ref)
  set(res)
  if(${ref} STREQUAL HEAD)
    map_new()
    ans(res)
    map_set(${res} type HEAD)
    map_set(${res} name HEAD)
  endif()
  if("${ref}" MATCHES "^refs/([^/]*)/(.*)$")
    string(REGEX REPLACE "^refs/([^/]*)/(.*)$" "\\1;\\2" parts "${ref}")
    list_extract(parts type name)
    map_new()
    ans(res)
    map_set(${res} type ${type})
    map_set(${res} name ${name})
  endif()
  return_ref(res)
endfunction()




function(git_repository_name repository_uri)
  get_filename_component(repo_name "${repository_uri}" NAME_WE)
  return("${repo_name}")
endfunction()




# returns a list of ref maps containing the fields 
# name type and revision
function(git_remote_refs uri)
  git_uri("${uri}")
  ans(uri)
  git(ls-remote "${uri}" --result)
  ans(result)

  map_tryget(${result} result)
  ans(error)
  map_tryget(${result} output)
  ans(res)

  if(error)
    return()
  endif()

  string_split( "${res}" "\n")
  ans(lines)
  set(res)
  foreach(line ${lines})
    string(STRIP "${line}" line)

    # match
    if("${line}" MATCHES "^([0-9a-fA-F]*)\t(.*)$")
      string(REGEX REPLACE "^([0-9a-fA-F]*)\t(.*)$" "\\1;\\2" parts "${line}")
      list_extract(parts revision ref)
      git_ref_parse("${ref}")
      ans(ref_map)
      if(ref_map)
        map_set(${ref_map} revision ${revision})
        set(res ${res} ${ref_map})
        #ref_print(${ref_map})
      endif()
    endif()
  endforeach()   
  return_ref(res)
endfunction()




# convenience function for accessing hg
# use cd() to navigate to working directory
# usage is same as hg command line client
# syntax differs: hg arg1 arg2 ... -> hg(arg1 arg2 ...)
# add a --result flag to get a object containing return code
# input args etc.
# else only console output is returned
function(hg)
  find_package(Hg)
  if(NOT HG_FOUND)
    message(FATAL_ERROR "mercurial is not installed")
  endif()

   wrap_executable(hg "${HG_EXECUTABLE}")
   hg(${ARGN})
   return_ans()

endfunction()





function(hg_repository_name repository_uri)
  get_filename_component(repo_name "${repository_uri}" NAME_WE)
  return("${repo_name}")
endfunction()






function(hg_match_refs search)
  hg_get_refs()
  ans(refs)


  list_match(refs "{name:$search}")
  ans(m1)

  list_match(refs "{number:$search}")
  ans(m2)
  list_match(refs "{hash:$search}")
  ans(m3)
  list_match(refs "{type:$search}")
  ans(m4)
  set(res ${m1} ${m2} ${m3} ${m4})
  return_ref(res)
endfunction()






 function(hg_constraint)
  map_has_all("${ARGN}" uri branch)
  ans(is_hg_constraint)
  if(is_hg_constraint)
    return("${ARGN}")
  endif() 

  package_query("${ARGN}")
  ans(pq)

  map_new()
  ans(constraint)
  nav(hg_constraint = pq.package_constraint)

  string_split_at_last(repo_uri branch "${hg_constraint}" "@")
  if(NOT branch)
    set(branch "default")
  endif()
  map_set(${constraint} uri "${repo_uri}")
  map_set(${constraint} "branch" ${branch})
  return (${constraint})
 endfunction()

 
function(line_info)
  set(t1 ${CMAKE_CURRENT_LIST_FILE})
  set(t2 ${CMAKE_CURRENT_LIST_LINE})
  obj("{
    file:$t1,
    line:$t2
    }")

  json_print(${__ans})
endfunction()





function(hg_get_refs)
  hg(branches)
  ans(branches)
  string_split("${branches}" "\n")
  hg(branches)
  ans(tags)  
  string_split("${tags}" "\n")
  ans(tags)


  set(refs)
  foreach(ref ${tags}  )
    hg_parse_ref("${ref}")
    ans(ref)
    map_set("${ref}" type "tag")
    list(APPEND refs "${ref}") 
  endforeach()
  foreach(ref ${branches}  )
    hg_parse_ref("${ref}" )
    ans(ref)
    map_set("${ref}" type "branch")
    list(APPEND refs "${ref}") 
  endforeach()
  return_ref(refs)
endfunction()





# returns true iff the uri is a hg repository
function(hg_remote_exists uri)
  hg(identify "${uri}" --result)
  ans(result)
  map_tryget(${result} result)
  ans(error)

  if(NOT error)
    return(true)
  endif()
  return(false)
endfunction()





# parses a hg ref (e.g. result of hg tags ) returning a map
# { name: <identifier>, number:<int>, id:<hash>}
function(hg_parse_ref)
 string(REGEX REPLACE "^_([a-zA-Z0-9_\\.\\/\\-]+)[ ]+([0-9]+):([0-9a-fA-F]+)(.*)$" "\\1;\\2;\\3;\\4" parts "_${ref}")
  map_new()
  ans(ref_struct)
  list_extract(parts name rev_number rev rest)
  if("${rest}" MATCHES "\\(inactive\\)")
    map_set(${ref_struct} inactive true)
  else()
    map_set(${ref_struct} inactive false)
  endif()


  map_set(${ref_struct} name "${name}")
  map_set(${ref_struct} number "${rev_number}")
  map_set(${ref_struct} hash "${rev}")
  return_ref(ref_struct)
endfunction()






function(hg_ref  search)
  hg_match_refs("${search}")
  ans(res)
  list(LENGTH res len)
  if("${len}" EQUAL 1)
    return(${res})
  endif()
  return()
endfunction()







    function(hg_cached_clone target_dir uri ref)
      set(args ${ARGN})
      list_extract_flag(args --async)
      ans(async)
      pushd("${target_dir}" --create)
      ans(target_dir)
      path_qualify(target_dir)


      if(async)
        ## this actually works...
        set(script "
          include(${oocmake_base_dir}/cmakepp.cmake)
          hg(clone ${remote_uri} ${target_dir})
          hg(update)
          set(ref ${ref})
          if(ref)
            hg(checkout ${ref})
          endif()
        ")
        process_start_script("${script}")
        ans(process_handle)

        echo_append("cloning hg repository '${uri}' ...")
        while(true)
          process_isrunning(${process_handle})
          ans(running)
          if(NOT running)
            break()
          endif()
          echo_append(".")
        endwhile()
        message("... done")

        process_wait(${process_handle})
        ans(res)
        return_ref(target_dir)
      else()

        hg(clone "${remote_uri}" "${target_dir}")
        hg(update)
        if(ref)
          hg(checkout "${ref}")
        endif()
        popd()
        return_ref(target_dir)
      endif()
    endfunction()





  function(ref_prop_get ref prop)
    map_get_special("${ref}" object)
    ans(isobject)
    if(isobject)
      obj_get("${ref}" "${prop}")
    else()
      map_tryget("${ref}" "${prop}")
    endif()
    return_ans()
  endfunction()




## generates a header file from a class definition
  function(cpp_class_header_generate class_def)
    data("${class_def}")
    ans(class_def)
  

    indent_level_push(0)
    set(source)
    string_append_line_indented(source "#pragma once")
    string_append_line_indented(source "")

    cpp_class_generate("${class_def}")
    ans(class_source)
    set(source "${source}${class_source}")


    string_append_line_indented(source "")

    indent_level_pop()
    return_ref(source)
  endfunction()






  function(cpp_class_generate class_def)
    data("${class_def}")
    ans(class_def)

    map_tryget(${class_def} namespace)
    ans(namespace)


    map_tryget(${class_def} type_name)
    ans(type_name)

    indent_level_push(0)

    set(source)

    string(REPLACE "::" ";" namespace_list "${namespace}")

    foreach(namespace ${namespace_list})
      string_append_line_indented(source "namespace ${namespace}{")
      indent_level_push(+1)
    endforeach()


    string_append_line_indented(source "class ${type_name}{")
    indent_level_push(+1)


    indent_level_pop()
    string_append_line_indented(source "};")


    foreach(namespace ${namespace_list})
      indent_level_pop()
      string_append_line_indented(source "}")
    endforeach()



    indent_level_pop()
    # namespace
    # struct/class
    # inheritance
    # fields
    # methods
    return_ref(source)

  endfunction()





function(dbg)
  set(args ${ARGN})
  list_extract_flag(args --indented)
  ans(indented)
  if(NOT args)
    set(last_return_value "${__ans}")
    set(args last_return_value)
  endif()
  if("${args}")
    map_isvalid("${${args}}")
    ans(ismap)
    if(ismap)
      if(indented)
        json_indented("${${args}}")
      else()
        json("${${args}}")
      endif()
      ans("${args}")
    endif()
    dbg("${args}: '${${args}}'")
    return()
  endif()
  list_length(args)
  ans(len)
  if("${len}" EQUAL 1)
    map_isvalid("${args}")
    ans(ismap)
    if(ismap)  
      if(indented)
        json_indented("${args}")
      else()
        json("${args}")
      endif()
      ans("${args}")

    endif()
    message(FORMAT "dbg (${__function_call_func}): '${args}'")
    return()
  endif()

  foreach(arg ${args})
    dbg("${arg}")
  endforeach()

  return()
endfunction()




# evaluates a cmake math expression and returns its
# value
function(eval_math)
  math(EXPR res ${ARGN})
  return_ref(res)
endfunction()





function(include_once file)
  get_filename_component(file "${file}" REALPATH)
  string(MD5 md5 "${file}")
  get_property(wasIncluded GLOBAL PROPERTY "include_guards.${md5}")
  if(wasIncluded)
  	return()
  endif()
  set_property(GLOBAL PROPERTY "include_guards.${md5}" true)
  include("${file}")
endfunction()




macro(promote var_name)
  set(${var_name} ${${var_name}} PARENT_SCOPE)
endmacro()  




## returns true iff cmake is currently in script mode
function(is_script_mode)
 commandline_get()
 ans(args)

 list_extract(args command P path)
 if("${P}" STREQUAL "-P")
  return(true)
else()
  return(false)
 endif()
endfunction()

## returns the file that was executed via script mode
function(script_mode_file)
  commandline_get()
  ans(args)

 list_extract(args command P path)
if(NOT "${P}" STREQUAL "-P")
  return()
endif()
  path("${path}")
  ans(path)
  return_ref(path)
endfunction()






## fails if ARGN does not match expected value
## see map_match
function(assert_matches expected)
  assign(expected = ${expected})
  assign(actual = ${ARGN})
  map_match("${actual}" "${expected}")
  ans(result)
  if(NOT result)
    echo_append("expected: ")
    json_print(${expected})
    echo_append("actual:")
    json_print(${actual})
    _message(FATAL_ERROR "values did not match")
  endif()
endfunction()





  function(ascii_code char)
    generate_ascii_table()
    map_tryget(ascii_table "'${char}'")
    return_ans()
  endfunction()




# converts a decimal number to a hexadecimal string
# e.g. dec2hex(195936478) => "BADC0DE"

  function(dec2hex n)
    set(rest ${n})
    set(converted)

    if("${n}" EQUAL 0)
      return(0)
    endif()
    
    while(${rest} GREATER 0)
      math(EXPR c "${rest} % 16")
      math(EXPR rest "(${rest} - ${c})>> 4")

      if("${c}" LESS 10)
        list(APPEND converted "${c}")
      else()
        if(${c} EQUAL 10)
          list(APPEND converted A)
        elseif(${c} EQUAL 11)
          list(APPEND converted B)
        elseif(${c} EQUAL 12)
          list(APPEND converted C)
        elseif(${c} EQUAL 13)
          list(APPEND converted D)
        elseif(${c} EQUAL 14)
          list(APPEND converted E)
        elseif(${c} EQUAL 15)
          list(APPEND converted F)
        endif()
      endif()
    endwhile()
    list(LENGTH converted len)
    if(${len} LESS 2)
      return(${converted})
    endif()
    list(REVERSE converted)
    string_combine("" ${converted})
    return_ans()
  endfunction() 





  macro(return_nav)
    assign(result = ${ARGN})
    return_ref(result)
  endmacro()





#include guard returns if the file was already included 
# usage :  at top of file write include_guard(${CMAKE_CURRENT_LIST_FILE})
macro(include_guard __include_guard_file)
  #string(MAKE_C_IDENTIFIER "${__include_guard_file}" __include_guard_file)
  get_property(is_included GLOBAL PROPERTY "ig_${__include_guard_file}")
  if(is_included)
    _return()
  endif()
  set_property(GLOBAL PROPERTY "ig_${__include_guard_file}" true)
endmacro()






function(message_indent_push)
  
  set(new_level ${ARGN})
  if("${new_level}_" STREQUAL "_")
    set(new_level +1)
  endif()
  
  if("${new_level}" MATCHES "[+\\-]")
    message_indent_level()
    ans(previous_level)
    math(EXPR new_level "${previous_level} ${new_level}")
    if(new_level LESS 0)
      set(new_level 0)
    endif()
  endif()
  map_push_back(global message_indent_level ${new_level})
  return(${new_level})
endfunction()





# Evaluate expression
# Suggestion from the Wiki: http://cmake.org/Wiki/CMake/Language_Syntax
# Unfortunately, no built-in stuff for this: http://public.kitware.com/Bug/view.php?id=4034
# eval will not modify ans (the code evaluated may modify ans)
# variabls starting with __eval should not be used in code
function(eval code)

  # variables which come before incldue() are obfuscated names so that
  # they do not clutter the scope
  
  # retrieve current ans value  
  ans(__eval_current_ans)
  
  oocmake_config(temp_dir)
  ans(__eval_temp_dir)

  file_random( "${__eval_temp_dir}/eval_{{id}}.cmake")
  ans(__eval_file_name)


  file(WRITE ${__eval_file_name} "${code}")


  # restore current ans value and execute code
  set_ans("${__eval_current_ans}")
  include(${__eval_file_name})
  ans(res)

  oocmake_config(keep_temp)
  ans(keep_temp)
  if(NOT keep_temp)
    file(REMOVE ${__eval_file_name})
  endif()

  return_ref(res)
endfunction()


# Evaluate expression (faster version)
# Suggestion from the Wiki: http://cmake.org/Wiki/CMake/Language_Syntax
# Unfortunately, no built-in stuff for this: http://public.kitware.com/Bug/view.php?id=4034
# eval will not modify ans (the code evaluated may modify ans)
# vars starting with __eval should not be used in code
function(eval __eval_code)
  
  # one file per execution of cmake (if this file were in memory it would probably be faster...)
  file_make_temporary("")
  ans(__eval_temp_file)


# speedup: statically write filename so eval boils down to 2 function calls
# no need to keep __ans
 file(WRITE "${__eval_temp_file}" "
function(eval __eval_code)
  file(WRITE \"${__eval_temp_file}\" \"\${__eval_code}\")
  include(\"${__eval_temp_file}\")
  return_ans()
endfunction()
  ")
include("${__eval_temp_file}")


eval("${__eval_code}")
return_ans()
endfunction()







# creates a value descriptor
# available options are
# REQUIRED
# available Single Value args
# DISPLAY_NAME
# DESCRIPTION
# MIN
# MAX
# Multi value args
# LABELS
# DEFAULT 

function(value_descriptor_parse id)
  set(ismap)
  set(descriptor)
  if(${ARGC} EQUAL 1)
    set(args ${ARGN})
    # it might be a map
    list_peek_front(args)
    ans(first)
    map_isvalid("${first}" )
    ans(ismap)

    if(ismap)
      message(ismap)
      set(descriptor ${ARGV1})
    endif()
  endif()

  if(NOT descriptor)
    map_new()
    ans(descriptor)
  endif()
  
  # set default values
  map_navigate_set_if_missing("descriptor.labels" "${id}")
  map_navigate_set_if_missing("descriptor.displayName" "${id}")
  map_navigate_set_if_missing("descriptor.min" "0")
  map_navigate_set_if_missing("descriptor.max" "1")
  map_navigate_set_if_missing("descriptor.id" "${id}")
  map_navigate_set_if_missing("descriptor.description" "")
  map_navigate_set_if_missing("descriptor.default" "")
  if(ismap)
    return(${descriptor})
  endif()

  cmake_parse_arguments("" "REQUIRED" "DISPLAY_NAME;DESCRIPTION;MIN;MAX" "LABELS;DEFAULT" ${ARGN})

  if(_DISPLAY_NAME)
    map_navigate_set(descriptor.displayName "${_DISPLAY_NAME}")
  endif()

  if(_DESCRIPTION)
    map_navigate_set(descriptor.description "${_DESCRIPTION}")
  endif()
  #message("_MIN ${_MIN}")
  if("_${_MIN}" MATCHES "^_[0-9]+$")
    map_navigate_set(descriptor.min "${_MIN}")
  endif()


#  message("_MAX ${_MAX}")
  if("_${_MAX}" MATCHES "^_[0-9]+|\\*$")        
    map_navigate_set(descriptor.max "${_MAX}")
  endif()

  if(_LABELS)
    map_navigate_set(descriptor.labels "${_LABELS}")
  endif()

  if(_DEFAULT)
    map_navigate_set(descriptor.default "${_DEFAULT}")
  endif()

  return(${descriptor})

endfunction()




# returns the identifier for the os being used
function(os)
  if(WIN32)
    return(Windows)
  elseif(UNIX)
    return(Linux)
  else()
    return()
  endif()


endfunction()






  macro(return_data data)
    data("${data}")
    return_ans()
  endmacro()




## prints str to console without reformatting it and no message type
function(print str)
  _message("${str}")
endfunction()




#adds a values to parent_scopes __ans
function(yield)
    set(__yield_tmp ${__yield_tmp} ${ARGN} PARENT_SCOPE)

endfunction()




# returns the list of command line arguments
function(commandline_string)
  set(args)
  foreach(i RANGE ${CMAKE_ARGC})  
    set(current ${CMAKE_ARGV${i}})
    string(REPLACE \\ / current "${current}")
    set(args "${args} ${current}")
    
  endforeach()  

  return_ref(args)
endfunction() 





# returns the list of command line arguments
function(commandline_arg_string)
  set(args)
  foreach(i RANGE 3 ${CMAKE_ARGC})  
    set(current ${CMAKE_ARGV${i}})
    string(REPLACE \\ / current "${current}")
    set(args "${args} ${current}")
    
  endforeach()  

  return_ref(args)
endfunction() 





## returns the number of milliseconds since epoch
function(millis)

  compile_tool(millis "
    #include <iostream>
    #include <chrono>
    int main(int argc, const char ** argv){
     //std::cout << \"message(whatup)\"<<std::endl;
     //std::cout << \"obj(\\\"{id:'1'}\\\")\" <<std::endl;
     auto now = std::chrono::system_clock::now();
     auto duration = now.time_since_epoch();
     auto millis = std::chrono::duration_cast<std::chrono::milliseconds>(duration).count();
     std::cout<< \"set_ans(\" << millis << \")\";
     return 0;
    }"
    )
  millis(${ARGN})
  return_ans()
endfunction()




function(message_indent_level)
  map_peek_back("global" "message_indent_level")
  ans(level)
  if(NOT level)
    return(0)
  endif()
  return_ref(level)
endfunction()








function(message)
	cmake_parse_arguments("" "PUSH_AFTER;POP_AFTER;DEBUG;INFO;FORMAT;PUSH;POP" "LEVEL" "" ${ARGN})
	set(log_level ${_LEVEL})
	set(text ${_UNPARSED_ARGUMENTS})

	## indentation
	if(_PUSH)
		message_indent_push()
	endif()
	if(_POP)
		message_indent_pop()
	endif()


	message_indent_get()
	ans(indent)
	if(_POP_AFTER)
		message_indent_pop()
	endif()
	if(_PUSH_AFTER)
		message_indent_push()
	endif()
	## end of indentationb


	## log_level
	if(_DEBUG)
		if(NOT log_level)
			set(log_level 3)
		endif()
		set(text STATUS ${text})
	endif()
	if(_INFO)
		if(NOT log_level)
			set(log_level 2)
		endif()
		set(text STATUS ${text})
	endif()
	if(NOT log_level)
		set(log_level 0)
	endif()

	if(NOT MESSAGE_LEVEL)
		set(MESSAGE_LEVEL 3)
	endif()

	list(GET text 0 modifier)
	if(${modifier} MATCHES "FATAL_ERROR|STATUS|AUTHOR_WARNING|WARNING|SEND_ERROR|DEPRECATION")
		list(REMOVE_AT text 0)
	else()
		set(modifier)
	endif()

	## format
	if(_FORMAT)
		map_format( "${text}")
		ans(text)
	endif()

	if(NOT MESSAGE_DEPTH )
		set(MESSAGE_DEPTH -1)
	endif()

	if(NOT text)
		return()
	endif()

	map_new()
	ans(message)
	map_set(${message} text "${text}")
	map_set(${message} indent_level ${message_indent_level})
	map_set(${message} log_level ${log_level})
	map_set(${message} mode "${modifier}")
	event_emit(on_message ${message})

	if(log_level GREATER MESSAGE_LEVEL)
		return()
	endif()
	if(MESSAGE_QUIET)
		return()
	endif()
	# check if deep message are to be ignored
	if(NOT MESSAGE_DEPTH LESS 0)
		if(${message_indent_level} GREATER ${MESSAGE_DEPTH})
			return()
		endif()
	endif()

	tock()
	
	_message(${modifier} "${indent}" "${text}")


	
	return()
endfunction()







  function(graphsearch)
    cmake_parse_arguments("" "" "EXPAND;PUSH;POP" "" ${ARGN})

    if(NOT _EXPAND)
      message(FATAL_ERROR "graphsearch: no expand function set")
    endif()

    function_import("${_EXPAND}" as gs_expand REDEFINE)
    function_import("${_PUSH}" as gs_push REDEFINE)
    function_import("${_POP}" as gs_pop REDEFINE)

    # add all arguments to stack
    foreach(node ${_UNPARSED_ARGUMENTS})

      gs_push(${node})
    endforeach()

    # iterate
    while(true)
      gs_pop()
      ans(current)
      #message("current ${current}")
      # recursion anchor - no more node
      if(NOT current)
        break()
      endif()
      gs_expand(${current})
      ans(successors)
      foreach(successor ${successors})
        gs_push(${successor})
      endforeach()
      
    endwhile()
  endfunction()





function(message_indent_get)
  message_indent_level()
  ans(level)
  string_repeat(" " ${level})
  return_ans()
endfunction()






  function(require_include_dirs )
    require_map()
    ans(map)
    map_get(${map}  include_dirs)
    ans(stack)
    stack_pop(${stack})
    ans(dirs)
    list(APPEND dirs ${ARGN})
    stack_push(${stack} ${dirs})

  endfunction()






function(yield_begin)
  set(__yield_tmp PARENT_SCOPE)
endfunction()





# convenience function for accessing cmake
# use cd() to navigate to working directory
# usage is same as cmake command line client
# syntax differs: cmake arg1 arg2 ... -> cmake(arg1 arg2 ...)
# add a --result flag to get a object containing return code
# input args etc.
# else only console output is returned
function(cmake)
  wrap_executable(cmake "${CMAKE_COMMAND}")
  cmake(${ARGN})
  return_ans()
endfunction() 





# spawns an interactive cmake session
# use @echo off and @echo on to turn printing of result off and on
# use quit or exit to terminate
# usage: cmake()
function(icmake)
  # outer loop loops untul quit or exit is input
  set(echo on)
  set(strict off)
  while(true)
    pwd()
    ans(pwd)
    echo_append("${pwd} icmake> ")
    set(cmd)
    # inner loop for reading multiline inputs (delimited by \)
    set(line "\\")
    set(first true)
    while("${line}" MATCHES ".*\\\\$")
      if(first)
        set(first false)
        set(line "")
      else()
        echo_append("        ")
      endif()

      read_line()
      ans(line)
      if("${line}" MATCHES ".*\\\\$")
        string_slice("${line}" 0 -2)
        ans(theline)
      else()
        set(theline "${line}")
      endif()
      set(cmd "${cmd}\n${theline}")

    endwhile()
    if("${line}" MATCHES "^(quit|exit)$")
      break()
    endif()

    if("${cmd}" MATCHES "@echo on")
      message("echo is now on")
      set(echo on)
      break()
    elseif("${cmd}" MATCHES "@echo off")
      message("echo is now off")
      set(echo off)
      break()
    elseif("${cmd}" MATCHES "@string off")
      message("strict is now off")
      set(strict off)
    elseif("${cmd}" MATCHES "@string on")
      message("strict is no on")
      set(strict on)
    else()
      # check if cmd is valid cmake
        #todo
      if(NOT strict)
        lazy_cmake("${cmd}")
        ans(cmd)
      endif()
      set_ans("${ANS}")
      eval_ref(cmd)
      ans(ANS)
      if(echo)
        json_print(${ANS})
      endif()
    endif()
  endwhile()
  return()
endfunction()




# returns the list of command line arguments
function(commandline_get)
  set(args)
  foreach(i RANGE ${CMAKE_ARGC})  
    set(current ${CMAKE_ARGV${i}})
    string(REPLACE \\ / current "${current}")
    list(APPEND args "${current}")    
  endforeach()  

  return_ref(args)
endfunction() 


## 
##
## returns script | configure | build
function(cmake_mode)

endfunction()





#includes all files identified by globbing expressions
# see file_glob on globbing expressions
function(include_glob)
  set(args ${ARGN})
  file_glob(${args})
  ans(files)
  foreach(file ${files})
    include_once("${file}")
  endforeach()

  return()
endfunction()






# queries the system for the current datetime
# returns a map containing all elements of the current date
# {yyyy: <>, MM:<>, dd:<>, hh:<>, mm:<>, ss:<>, ms:<>}

function(datetime)
  file_make_temporary("")
  ans(file)
  file_timestamp("${file}")
  ans(timestamp)
  rm("${file}")


  string(REGEX REPLACE "([0-9][0-9][0-9][0-9])\\-([0-9][0-9])\\-([0-9][0-9])T([0-9][0-9]):([0-9][0-9]):([0-9][0-9])"
   "\\1;\\2;\\3;\\4;\\5;\\6" 
   timestamp 
   "${timestamp}")
  
  list_extract(timestamp yyyy MM dd hh mm ss)
  set(ms 0)

  map_new()
  ans(dt)
  map_capture(${dt} yyyy MM dd hh mm ss ms)
  return_ref(dt)





  # old implementation
  shell_get()
  ans(shell)
  map_new()
  ans(dt)
  if("${shell}" STREQUAL cmd)
    shell_env_get("time")
    ans(time)
    shell_env_get("date")
    ans(date)
    
    string(REGEX REPLACE "([0-9][0-9])\\.([0-9][0-9])\\.([0-9][0-9][0-9][0-9]).*" "\\1;\\2;\\3" date "${date}")
    list_extract(date dd MM yyyy)
    

    string(REGEX REPLACE "([0-9][0-9]):([0-9][0-9]):([0-9][0-9]),([0-9][0-9]).*" "\\1;\\2;\\3;\\4" time "${time}")
    list_extract(time hh mm ss ms)

    map_capture(${dt} yyyy MM dd hh mm ss ms)

    return("${dt}")
  else()

    message(WARNING "oocmake's datetime is not implemented  for your system")
    set(yyyy)
    set(MM)
    set(dd)
    set(hh)
    set(mm)
    set(ss)
    set(ms)
    
    map_capture(${dt} yyyy MM dd hh mm ss ms)

    return("${dt}")

  endif()
endfunction()




function(scope_resolve key)
  map_has("${local}" "${key}")
  ans(has_local)
  if(has_local)
    map_tryget("${local}" "${key}")
    return_ans()
  endif()

  obj_get("${this}" "${key}")
  return_ans()
endfunction()   




# sleeps for the specified amount of seconds
function(sleep seconds)
  if("${CMAKE_MAJOR_VERSION}" LESS 3)
    if(UNIX)
      execute_process(COMMAND sleep ${seconds} RESULT_VARIABLE res)

      if(NOT "${res}" EQUAL 0)
        message(FATAL_ERROR "sleep failed")
      endif()
      return()
    endif()

    message(WARNING "sleep no available in cmake version ${CMAKE_VERSION}")
    return()
  endif()

  cmake(-E sleep "${seconds}")
  return()
endfunction()




# executes the topological sort for a list of nodes (passed as varargs)
# get_hash is a function to be provided which returns the unique id for a node
# this is used to check if a node was visited previously
# expand should take a node and return its successors
# this function will return nothing if there was a cycle or if no input was given
# else it will return the topological order of the graph
function(topsort get_hash expand)
  # visitor function
  function(topsort_visit result visited node)
    # get hash for current node
    call("${get_hash}" ("${node}"))
    ans(hash)

    map_tryget("${visited}" "${hash}")
    ans(mark)
    
    if("${mark}" STREQUAL "temp")
      #cycle found
      return(true)
    endif()
    if(NOT mark)
      map_set("${visited}" "${hash}" temp)
      call("${expand}" ("${node}"))
      ans(successors)
      # visit successors
      foreach(successor ${successors})
        topsort_visit("${result}" "${visited}" "${successor}")
        ans(cycle)
        if(cycle)
      #    message("cycle found")
          return(true)
        endif()
      endforeach()

      #mark permanently
      map_set("${visited}" "${hash}" permanent)

      # add to front of result
      ref_prepend("${result}" "${node}")
    endif()
    return(false)
  endfunction()


  map_new()
  ans(visited)
  ref_new()
  ans(result)

  # select unmarked node and visit
  foreach(node ${ARGN})
    # get hash for node
    call("${get_hash}" ("${node}"))
    ans(hash)
    
    # get marking      
    map_tryget("${visited}" "${hash}")
    ans(mark)
    if(NOT mark)
      topsort_visit("${result}" "${visited}" "${node}")
      ans(cycle)
      if(cycle)
       # message("stopping with cycle")
        return()
      endif()
    endif()

  endforeach()
#  message("done")
  ref_get(${result})

  return_ans()
endfunction()




# checks to see if an assertion holds true. per default this halts the program if the assertion fails
# usage:
# assert(<assertion> [MESSAGE <string>] [MESSAGE_TYPE <FATAL_ERROR|STATUS|...>] [RESULT <ref>])
# <assertion> := <truth-expression>|[<STRING|NUMBER>EQUALS <list> <list>]
# <truth-expression> := anything that can be checked in if(<truth-expression>)
# <list> := <ref>|<value>|<value>;<value>;...
# if RESULT is set then the assertion will not cause the program to fail but return the true or false
# if ACCU is set result is treated as a list and if an assertion fails the failure message is added to the end of result
# examples
# 
# assert("3" STREQUAL "3") => nothing happens
# assert("3" STREQUAL "b") => FATAL_ERROR assertion failed: '"3" STREQUAL "b"'
# assert(EXISTS "none/existent/path") => FATAL_ERROR assertion failed 'EXISTS "none/existent/path"' 
# assert(EQUALS a b) => FATAL_ERROR assertion failed ''
# assert(<assertion> MESSAGE "hello") => if assertion fails prints "hello"
# assert(<assertion> RESULT res) => sets result to false if assertion fails or to true if it holds
# assert(EQUALS "1;3;4;6;7" "1;3;4;6;7") => nothing happens lists are equal
# assert(EQUALS 1 2 3 4 1 2 3 4) =>nothing happes lists are equal (see list_equal)
# assert(EQUALS C<list> <list> COMPARATOR <comparator> )... todo
# todo: using the variable result as a boolean check fails because
# the name is used inside assert


function(assertf)
	set(args ${ARGN})
	list_extract_flag(args DEREF)
	assert(${args} DEREF)
	return()
endfunction()
function(assert)
	# parse arguments
	set(options EQUALS AREEQUAL ARE_EQUAL ACCU SILENT DEREF INCONCLUSIVE ISNULL ISNOTNULL)
	set(oneValueArgs  COUNT MESSAGE RESULT MESSAGE_TYPE CONTAINS MISSING MATCH MAP_MATCHES FILE_CONTAINS)
	set(multiValueArgs CALL PREDICATE )
	set(prefix)
	cmake_parse_arguments("${prefix}" "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
	#_UNPARSED_ARGUMENTS
	set(result)
 

	#if no message type is set set FATAL_ERROR
	# so execution halts on failing assertion
	if(NOT _MESSAGE_TYPE)
		set(_MESSAGE_TYPE FATAL_ERROR)
	endif()




	# if continue is set set the mesype to statussage t
	if(_RESULT AND _MESSAGE_TYPE STREQUAL FATAL_ERROR)
		set(_MESSAGE_TYPE STATUS)
	endif()

	if(_DEREF)
		map_format( "${_UNPARSED_ARGUMENTS}")
		ans(_UNPARSED_ARGUMENTS)
	endif()

	## transform call into further arguments
	if(_CALL)
		call(${_CALL})

		ans(vars)
		list(APPEND _UNPARSED_ARGUMENTS ${vars})
	endif()

	# 
	if(_EQUALS OR _ARE_EQUAL OR _AREEQUAL)
		if(NOT _MESSAGE)
		set(_MESSAGE "assertion failed: lists not equal [${_UNPARSED_ARGUMENTS}]")
		endif()
		list_equal(${_UNPARSED_ARGUMENTS})
		ans(result)
	elseif(_PREDICATE)
		if(NOT _MESSAGE)
			set(_MESSAGE "assertion failed: predicate does not hold: '${_PREDICATE}'")
		endif()
	#	message("predicate '${_PREDICATE}'")
		call(${_PREDICATE}(${_UNPARSED_ARGUMENTS}))
		ans(result)
	elseif(_FILE_CONTAINS)
		if(NOT _MESSAGE)
			set(_MESSAGE "assertion failed: file '${_FILE_CONTAINS}' does not contain: ${_UNPARSED_ARGUMENTS}")
		endif()
		file(READ "${_FILE_CONTAINS}" contents)
		if("${contents}" MATCHES "${_UNPARSED_ARGUMENTS}")
			set(result true)
		else()
			set(result false)
		endif()
	elseif(_INCONCLUSIVE)
		if(NOT _MESSAGE)
			set(_MESSAGE "assertion inconclusive")
		endif()
		set(result true)
	elseif(_MATCH)
		if(NOT _MESSAGE)
			set(_MESSAGE "assertion failed: input does not match '${_MATCH}'")
		endif()
		if("${_UNPARSED_ARGUMENTS}" MATCHES "${_MATCH}")
			set(result true)
		else()
			set(result false)
		endif()
	elseif(_COUNT OR "_${_COUNT}" STREQUAL _0)
			list(LENGTH _UNPARSED_ARGUMENTS len)
		if(NOT _MESSAGE)
			set(_MESSAGE "assertion failed: expected '${_COUNT}' elements got '${len}'")
		endif()
		eval_truth( "${len}" EQUAL "${_COUNT}")
		ans(result)
	elseif(_ISNULL)
		if("${_UNPARSED_ARGUMENTS}_" STREQUAL "_")
			set(result true)
		else()
			set(_MESSAGE "assertion failed: '${_UNPARSED_ARGUMENTS}' is not null")
			set(result false)
		endif()
	elseif(_ISNOTNULL)
		if("${_UNPARSED_ARGUMENTS}_" STREQUAL "_")
			set(result false)
		else()
			set(_MESSAGE "assertion failed: argument is null")
			set(result true)
		endif()
	elseif(_MAP_MATCHES)
		data("${_MAP_MATCHES}")
		ans(_MAP_MATCHES)
		map_match("${_UNPARSED_ARGUMENTS}" "${_MAP_MATCHES}")
		ans(result)
		if(NOT _MESSAGE)
			json("${_MAP_MATCHES}")
			ans(expected)
			json("${_UNPARSED_ARGUMENTS}")
			ans(actual)
			set(_MESSAGE "assertion failed: match failed: expected: '${expected}' actual:'${actual}'")
		endif()

	elseif(_CONTAINS OR _MISSING)
		if(NOT _MESSAGE)
		set(_MESSAGE "assertion failed: list does not contain '${_CONTAINS}' list:(${_UNPARSED_ARGUMENTS})")
		endif()
		list(FIND _UNPARSED_ARGUMENTS "${_CONTAINS}" idx)
		
		if(${idx} LESS 0)
			if(_MISSING)
				set(result true)
			else()
				set(result false)
			endif()
		else()
			if(_MISSING)
				set(result false)
			else()
				set(result true)
			endif()
		endif()

	else()
		# if nothing else is specified use _UNPARSED_ARGUMENTS as a truth expresion
		eval_truth( (${_UNPARSED_ARGUMENTS}))
		ans(result)
	endif()

	# if message is not set add default message
	if("${_MESSAGE}_" STREQUAL "_")
		list_to_string( _UNPARSED_ARGUMENTS " ")
		ans(msg)
		set(_MESSAGE "assertion failed1: '${_UNPARSED_ARGUMENTS}'")
	endif()

	# print message if assertion failed, SILENT is not specified or message type is FATAL_ERROR
	if(NOT result)
		if(NOT _SILENT OR _MESSAGE_TYPE STREQUAL "FATAL_ERROR")
			message(${_MESSAGE_TYPE} "'${_MESSAGE}'")
		endif()
	endif()

	# depending on wether to accumulate the results or not 
	# set result to a boolean or append to result list
	if(_ACCU)
		set(lst ${_RESULT})
		list(APPEND lst ${_MESSAGE})
		set(${_RESULT} ${lst} PARENT_SCOPE)
	else()
		set(${_RESULT} ${result} PARENT_SCOPE)
	endif()

endfunction()




# parses the command line string into parts (handling strings and semicolons)
function(parse_command_line result args)

  string(ASCII  31 ar)
  string(REPLACE "\;" "${ar}" args "${args}" )
  string(REGEX MATCHALL "((\\\"[^\\\"]*\\\")|[^ ]+)" matches "${args}")
  string(REGEX REPLACE "(^\\\")|(\\\"$)" "" matches "${matches}")
  string(REGEX REPLACE "(;\\\")|(\\\";)" ";" matches "${matches}")
# hack for windows paths
  string(REPLACE "\\" "/" matches "${matches}")
  set("${result}" "${matches}" PARENT_SCOPE)
endfunction()




# macro version of eval function which causes set(PARENT_SCOPE ) statements to access 
# scope of invokation
macro(eval_ref __eval_ref_theref)
  ans(__eval_ref_current_ans)
  oocmake_config(temp_dir)
  ans(__eval_ref_dir)

  file_random( "${__eval_ref_dir}/eval_{{id}}.cmake")
  ans(__eval_ref_filename)

  set_ans("${__eval_ref_current_ans}")
  file(WRITE ${__eval_ref_filename} "${${__eval_ref_theref}}")
  include(${__eval_ref_filename})
  ans(__eval_ref_res)
  

  oocmake_config(keep_temp)
  ans(__eval_ref_keep_temp)
  if(NOT __eval_ref_keep_temp)
    file(REMOVE ${__eval_ref_filename})
  endif()


  set_ans("${__eval_ref_res}")
endmacro()





function(require file)
  file(GLOB_RECURSE res "${file}")

  if(NOT res)
    message(FATAL_ERROR "could not find required file for '${file}'")
  endif()

  foreach(file ${res})
    include("${file}")
  endforeach()

endfunction()

#require(require_map)
#require(map_get)
#require(map_tryget)
#require(map_set)
#require(ans)
#require(return_ref)
#require(return)
#require(file_find)
#require(stack_peek)
#require(stack_push)
#require(stack_pop)
#function(require file)
#    message("require!!")
#    require_map()
#    ans(require_map)
#    map_get(${require_map}  include_dirs)
#    ans(stack)
  #  message("stack is ${stack}")
#    stack_peek(${stack})
#    ans(include_dirs)
#    #message("include dirs are ${include_dirs}")
#
#    get_filename_component(extension "${file}" EXT)
#    if(NOT extension)
#      set(file "${file}.cmake")
#    endif()
#
#    file_find("${file}" "${include_dirs}" "")
#    ans(result_file)
#
#    if(NOT result_file)
#      message(FATAL_ERROR "could not find file '${file}'")
#    endif()
#
#    map_tryget(${require_map} ${result_file})
#    ans(was_included)
#    if(was_included)
#      return()
#    endif()
#
#    get_filename_component(directory  "${result_file}" PATH)
#    stack_push(${stack} ${include_dirs} ${directory})
#    include(${result_file})
#    stack_pop(${stack})
#    map_set(${require_map} "${result_file}" true)
#
#    return_ref(result_file)
#endfunction()





## decodes an uri encoded string ie replacing codes %XX with their ascii values
 function(uri_decode str)
  set(hex "[0-9A-Fa-f]")
  set(encoded "%(${hex}${hex})")
  string(REGEX MATCHALL "${encoded}" matches "${str}")

  list(REMOVE_DUPLICATES matches)
  foreach(match ${matches})
    string(SUBSTRING "${match}" 1 -1  hex_code)
    hex2dec("${hex_code}")
    ans(dec_code)
    string(ASCII "${dec_code}" char)
    string(REPLACE "${match}" "${char}" str "${str}")
  endforeach()
  return_ref(str)

 endfunction()





function(compile files include_dirs)
  
  function(_compile files include_dirs already_included compiled_result)
        
    foreach(file ${files})
    #  message("compiling ${file}")
      file_find("${file}" "${include_dirs}" ".cmake")
      ans(full_path)

      if(NOT full_path)
        message(FATAL_ERROR "failed to find '${file}'")
      endif()
   #   message("found at ${full_path}")
      map_tryget(${already_included}  "${full_path}")
      ans(was_compiled)

      if(NOT was_compiled)
        map_set(${already_included} "${full_path}" true)
      #  message("first encounter of ${full_path}")
        file(READ "${full_path}" content )      
       # message("content ${content}")
        string(REGEX MATCHALL "[ \t]*require\\(([^\\)]+)\\)[\r\t ]*\n" matches "${content}") 
        string(REGEX REPLACE "[ \t]*require\\(([^\\)]+)\\)[\r\t ]*\n" "\\n" content "${content}")

        set(required_files)
        foreach(match ${matches})
          string(STRIP "${match}" match)
          string(REGEX REPLACE "require\\(([^\\)]+)\\)" "\\1" match "${match}")
          list(APPEND required_files "${match}")
        endforeach()
      #  message("required_files ${required_files}")

      #  message_indent_push()
          _compile("${required_files}" "${include_dirs};${current_dir}" "${already_included}" "${compiled_result}")
       # message_indent_pop()
        ans(compiled)
      #  messagE("appending result: ${content}")
        ref_append_string(${compiled_result} "
${compiled}
## ${full_path}
${content}")


      endif()
    endforeach()

  endfunction()
  map_new()
  ans(already_included)
  ref_new()
  ans(compiled_result)
  _compile("${files}" "${include_dirs}" "${already_included}" "${compiled_result}")
  ref_get(${compiled_result} )
  ans(res)
 # message("yay ${res}")
  return_ref(res)
endfunction()





function(cmakepp_cli)
  ## get command line args and remove executable -P and script file
  commandline_args_get(--no-script)
  ans(args)

  ## get format
  list_extract_flag(args --json)
  ans(json)
  list_extract_flag(args --qm)
  ans(qm)
  list_extract_flag(args --table)
  ans(table)
  list_extract_flag(args --csv)
  ans(csv)
  list_extract_flag(args --xml)
  ans(xml)
  list_extract_flag(args --string)
  ans(string)
  list_extract_flag(args --ini)
  ans(ini)

  string_combine(" " ${args})
  ans(lazy_cmake_code)

  lazy_cmake("${lazy_cmake_code}")
  ans(cmake_code)

  ## execute code
  set_ans("")
  eval("${cmake_code}")
  ans(result)


  ## serialize code
   if(json)
    json_indented("${result}")
    ans(result)
  elseif(ini)
    ini_serialize("${result}")
    ans(result)
   elseif(qm)
    qm_serialize("${result}")
    ans(result)
   elseif(table)
      table_serialize("${result}")
      ans(result)
    elseif(csv)
      csv_serialize("${result}")
      ans(result)
    elseif(xml)
      xml_serialize("${result}")
      ans(result)
    elseif(string)

    else()
      json_indented("${result}")
      ans(result)
   endif()



  ## print code
  echo("${result}")
endfunction()







## generates the ascii table and stores it in the global ascii_table variable  
  function(ascii_generate_table)
    foreach(i RANGE 1 255)
      string(ASCII ${i} c)
      map_set(ascii_table "'${char}'" "${i}")
      map_set(ascii_table "${i}" "${char}")
    endforeach()
    function(ascii_generate_table)
    endfunction()
  endfunction()







## characters specified in rfc2396
## 37 %  (percent)
## 126 ~ (tilde) 
## 1-32 (control chars) (nul is not allowed) 
## 127 (del)
## 32 (space)
## 35 (#) sharp fragment identifer
## 60 (<) 62 (>) 34 (") delimiters 
## unwise 
## 123 { 125 } 124 | 92 \ 94 ^ 91 [ 93 ] 96 `

function(uri_recommended_to_escape)
  ## control chars
  index_range(1 31)
  ans(dec_codes)

  
  list(APPEND dec_codes 
    32   # space
    34   # "
    35   # #
    60   # <
    62   # >
    91   # [
    93   # ]
    94   # ^ 
    96   # ` 
    123  # {
    124  # |
    125  # }
    127  # del
    )

  set(dec_codes
      37   # %  (this is prepended - important in uri_encode )
      ${dec_codes}
      )
  return_ref(dec_codes)



endfunction()





macro(promote_if_exists var_name)
  if(DEFINED ${var_name})
    promote(${var_name})
  endif()
endmacro()




# turns the lazy cmake code into valid cmake
#
function(lazy_cmake cmake_code)
# normalize cmake 
  # 
  string(STRIP "${cmake_code}" cmake_code )
  if(NOT "${cmake_code}" MATCHES "[ ]*[a-zA-Z0-9_]+\\(.*\\)[ ]*")
    string(REGEX REPLACE "[ ]*([a-zA-Z0-9_]+)[ ]*(.*)" "\\1(\\2)" cmd "${cmake_code}")
    string(REGEX REPLACE "[ ]*([a-zA-Z0-9_]+)[ ]*(.*)" "\\1" cmdname "${cmake_code}")
    if(NOT COMMAND "${cmdname}")
      string(STRIP "${cmake_code}" cc)
      set(cmd "set_ans(\"\${${cc}}\")")
    endif()
  endif()



  return_ref(cmd)

endfunction()




# returns a map of all set target properties for target
# if target does not exist it returns null
function(target_get_properties target)

  if(NOT TARGET "${target}")
    return()
  endif()
  set(props
    DEBUG_OUTPUT_NAME
    DEBUG_POSTFIX
    RELEASE_OUTPUT_NAME
    RELEASE_POSTFIX
    ARCHIVE_OUTPUT_DIRECTORY
    ARCHIVE_OUTPUT_DIRECTORY_DEBUG
    ARCHIVE_OUTPUT_DIRECTORY_RELEASE
    ARCHIVE_OUTPUT_NAME
    ARCHIVE_OUTPUT_NAME_DEBUG
    ARCHIVE_OUTPUT_NAME_RELEASE
    AUTOMOC
    AUTOMOC_MOC_OPTIONS
    BUILD_WITH_INSTALL_RPATH
    BUNDLE
    BUNDLE_EXTENSION
    COMPILE_DEFINITIONS
    COMPILE_DEFINITIONS_DEBUG
    COMPILE_DEFINITIONS_RELEASE
    COMPILE_FLAGS
    DEBUG_POSTFIX
    RELEASE_POSTFIX
    DEFINE_SYMBOL
    ENABLE_EXPORTS
    EXCLUDE_FROM_ALL
    EchoString
    FOLDER
    FRAMEWORK
    Fortran_FORMAT
    Fortran_MODULE_DIRECTORY
    GENERATOR_FILE_NAME
    GNUtoMS
    HAS_CXX
    IMPLICIT_DEPENDS_INCLUDE_TRANSFORM
    IMPORTED
    IMPORTED_CONFIGURATIONS
    IMPORTED_IMPLIB
    IMPORTED_IMPLIB_DEBUG
    IMPORTED_IMPLIB_RELEASE
    IMPORTED_LINK_DEPENDENT_LIBRARIES
    IMPORTED_LINK_DEPENDENT_LIBRARIES_DEBUG
    IMPORTED_LINK_DEPENDENT_LIBRARIES_RELEASE
    IMPORTED_LINK_INTERFACE_LANGUAGES
    IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG
    IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE
    IMPORTED_LINK_INTERFACE_LIBRARIES
    IMPORTED_LINK_INTERFACE_LIBRARIES_DEBUG
    IMPORTED_LINK_INTERFACE_LIBRARIES_RELEASE
    IMPORTED_LINK_INTERFACE_MULTIPLICITY
    IMPORTED_LINK_INTERFACE_MULTIPLICITY_DEBUG
    IMPORTED_LINK_INTERFACE_MULTIPLICITY_RELEASE
    IMPORTED_LOCATION
    IMPORTED_LOCATION_DEBUG
    IMPORTED_LOCATION_RELEASE
    IMPORTED_NO_SONAME
    IMPORTED_NO_SONAME_DEBUG
    IMPORTED_NO_SONAME_RELEASE
    IMPORTED_SONAME
    IMPORTED_SONAME_DEBUG
    IMPORTED_SONAME_RELEASE
    IMPORT_PREFIX
    IMPORT_SUFFIX
    INCLUDE_DIRECTORIES
    INTERFACE_INCLUDE_DIRECTORIES
    INTERFACE_SYSTEM_INCLUDE_DIRECTORIES
    INSTALL_NAME_DIR
    INSTALL_RPATH
    INSTALL_RPATH_USE_LINK_PATH
    INTERPROCEDURAL_OPTIMIZATION
    INTERPROCEDURAL_OPTIMIZATION_DEBUG
    INTERPROCEDURAL_OPTIMIZATION_RELEASE
    LABELS
    LIBRARY_OUTPUT_DIRECTORY
    LIBRARY_OUTPUT_DIRECTORY_DEBUG
    LIBRARY_OUTPUT_DIRECTORY_RELEASE
    LIBRARY_OUTPUT_NAME
    LIBRARY_OUTPUT_NAME_DEBUG
    LIBRARY_OUTPUT_NAME_RELEASE
    LINKER_LANGUAGE
    LINK_DEPENDS
    LINK_FLAGS
    LINK_FLAGS_DEBUG
    LINK_FLAGS_RELEASE
    LINK_INTERFACE_LIBRARIES
    LINK_INTERFACE_LIBRARIES_DEBUG
    LINK_INTERFACE_LIBRARIES_RELEASE
    LINK_INTERFACE_MULTIPLICITY
    LINK_INTERFACE_MULTIPLICITY_DEBUG
    LINK_INTERFACE_MULTIPLICITY_RELEASE
    LINK_SEARCH_END_STATIC
    LINK_SEARCH_START_STATIC
    #LOCATION
    #LOCATION_DEBUG
    #LOCATION_RELEASE
    MACOSX_BUNDLE
    MACOSX_BUNDLE_INFO_PLIST
    MACOSX_FRAMEWORK_INFO_PLIST
    MAP_IMPORTED_CONFIG_DEBUG
    MAP_IMPORTED_CONFIG_RELEASE
    OSX_ARCHITECTURES
    OSX_ARCHITECTURES_DEBUG
    OSX_ARCHITECTURES_RELEASE
    OUTPUT_NAME
    OUTPUT_NAME_DEBUG
    OUTPUT_NAME_RELEASE
    POST_INSTALL_SCRIPT
    PREFIX
    PRE_INSTALL_SCRIPT
    PRIVATE_HEADER
    PROJECT_LABEL
    PUBLIC_HEADER
    RESOURCE
    RULE_LAUNCH_COMPILE
    RULE_LAUNCH_CUSTOM
    RULE_LAUNCH_LINK
    RUNTIME_OUTPUT_DIRECTORY
    RUNTIME_OUTPUT_DIRECTORY_DEBUG
    RUNTIME_OUTPUT_DIRECTORY_RELEASE
    RUNTIME_OUTPUT_NAME
    RUNTIME_OUTPUT_NAME_DEBUG
    RUNTIME_OUTPUT_NAME_RELEASE
    SKIP_BUILD_RPATH
    SOURCES
    SOVERSION
    STATIC_LIBRARY_FLAGS
    STATIC_LIBRARY_FLAGS_DEBUG
    STATIC_LIBRARY_FLAGS_RELEASE
    SUFFIX
    TYPE
    VERSION
    VS_DOTNET_REFERENCES
    VS_GLOBAL_WHATEVER
    VS_GLOBAL_KEYWORD
    VS_GLOBAL_PROJECT_TYPES
    VS_KEYWORD
    VS_SCC_AUXPATH
    VS_SCC_LOCALPATH
    VS_SCC_PROJECTNAME
    VS_SCC_PROVIDER
    VS_WINRT_EXTENSIONS
    VS_WINRT_REFERENCES
    WIN32_EXECUTABLE
    XCODE_ATTRIBUTE_WHATEVER
    IS_TEST_EXECUTABLE
  )
  map()
  kv(name ${target})
  kv(project_name ${PROJECT_NAME})


  foreach(property ${props})
    get_property(isset TARGET ${target} PROPERTY ${property} SET)
    if(isset)
        get_property(value TARGET ${target} PROPERTY ${property})
        key("${property}")
        val("${value}")    
    endif()
  endforeach()
  end()
  
  ans(res)
  return_ref(res)
endfunction()




function(require_map)
  map_set_hidden(:__require_map __type__ map)
  stack_new()
  ans(stack)
  map_set_hidden(:__require_map include_dirs ${stack})

  function(require_map)
    return(":__require_map")
  endfunction()
  require_map()
  return_ans()
endfunction()





  function(echo_append_indent)
    message_indent_get()
    ans(indent)

    echo_append("${indent} ${ARGN}")
    return()
  endfunction()




# returns a config value
function(oocmake key)

    if(${ARGN})
      set_property(GLOBAL PROPERTY "oocmake.${key}" "${ARGN}")
    endif()
    get_property(res GLOBAL PROPERTY "oocmake.${key}")
    set("${key}" "${res}" PARENT_SCOPE)
endfunction()




# evaluates a truth expression 'if' and returns true or false 
function(eval_truth)
  if(${ARGN})
    return(true)
  endif()
  return(false)
endfunction()





function(hex2dec str)

  string(LENGTH "${str}" len)
  if("${len}" LESS 1)
  elseif("${len}" EQUAL 1)
    if("${str}" MATCHES "[0-9]")
      return("${str}")
    elseif( "${str}" MATCHES "[aA]")
      return(10)
    elseif( "${str}" MATCHES "[bB]")
      return(11)
    elseif( "${str}" MATCHES "[cC]")
      return(12)
    elseif( "${str}" MATCHES "[dD]")
      return(13)
    elseif( "${str}" MATCHES "[eE]")
      return(14)
    elseif( "${str}" MATCHES "[fF]")
      return(15)
    else()
      # invalid character
      return()
    endif()
  else()
    math(EXPR len "${len} - 1")
    set(result 0)
    foreach(i RANGE 0 ${len})
      string_char_at("${i}" "${str}")
      ans(c)
      

      hex2dec("${c}")
      ans(c)
      if("${c}_" STREQUAL "_")
        
        # illegal char
        return()
      endif()
      
      math(EXPR result "${result} + (2 << ((${len}-${i})*4)) * ${c}")
    endforeach()
    math(EXPR result "${result} >> 1")
    return(${result})
  endif()
  return()
endfunction()




# assigns the result return by a functi on to the specified variable
# must be immediately called after funct ion call
# if no argument is passed current __ans will be cleared (this should be called at beginning of ffunc)
# the name ans stems from calculators ans and signifies the last answer
function(ans __ans_result)
  set(${__ans_result} "${__ans}" PARENT_SCOPE)
endfunction()





# used to clear the __ans variable. may also called inside a function with argument PARENT_SCOPE to clear
# parent __ans variable
macro(clr)
  set(__ans ${ARGN})
endmacro()





  macro(return_math expr)
    math(EXPR __return_math_res "${expr}")
    return(${__return_math_res})
  endmacro()







## appends the last return value to the specified list
macro(ans_append __lst)
  list(APPEND ${__lst} ${__ans})
endmacro()




# returns the var called ${ref}
# this inderection is needed when returning escaped string, else macro will evaluate the string
macro(return_ref __return_ref_ref)
  set(__ans "${${__return_ref_ref}}" PARENT_SCOPE)
  _return()
endmacro()




#returns the last returned value
# this is a shorthand useful when returning the rsult of a previous function
macro(return_ans)
  return_ref(__ans)
endmacro()





macro(return)
  set(__ans "${ARGN}" PARENT_SCOPE)
	_return()
endmacro()




function(set_ans __set_ans_val)
  return_ref(__set_ans_val)
endfunction()




macro(return_reset)
  set(__ans PARENT_SCOPE)
endmacro()




macro(return_truth)
  if(${ARGN})
    return(true)
  endif()
  return(false)
endmacro()





function(set_ans_ref __set_ans_ref_ref)
  return_ref("${__set_ans_ref_ref}")

endfunction()




function(cached arg)
    json("${arg}")
    ans(ser)
    string(MD5 cache_key "${ser}")
    set(args ${ARGN})
    list(LENGTH args arg_len)
    if(arg_len)

      map_set(global_cache_entries "${cache_key}" "${args}")
      return_ref(args)
    endif()


    map_tryget(global_cache_entries "${cache_key}")    
    ans(res)
    return_ref(res)


endfunction()

  macro(return_hit arg_name)
    cached("${${arg_name}}")
    if(__ans)
      message("hit")
      return_ans()
    endif()
      message("not hit")
  endmacro()








function(math_min a b)
  if(${a} LESS ${b})
    return(${a})
  else()
    return(${b})
  endif() 
endfunction()





function(tock)
  map_tryget(globaltick val)
  ans(res)
  if(res)
    _message("")
    map_set(globaltick val false)
  endif()
endfunction()




## compile_oocmake() 
##
## compiles cmakepp into a single file which is faster to include
function(compile_oocmake source_dir target)
  set(base_dir ${source_dir})

#  file(READ "${base_dir}/resources/expr.json" data)
#  get_filename_component(res "${target}" "PATH")

 # file(WRITE "${res}/resources/expr.json" "${data}")


  file(STRINGS "${base_dir}/cmakepp.cmake" oocmake_file)

  foreach(line ${oocmake_file})
    if("_${line}" STREQUAL "_include(\"\${oocmake_base_dir}/cmake/core/require.cmake\")")

    elseif("_${line}" STREQUAL "_require(\"\${oocmake_base_dir}/cmake/*.cmake\")")

      file(GLOB_RECURSE files "${base_dir}/cmake/**.cmake")

      foreach(file ${files} ) 
        file(READ  "${file}" content)      
        file(APPEND "${target}" "\n\n\n${content}\n\n")
      endforeach()
    else()
      file(APPEND "${target}" "${line}\n")
  endif()
  endforeach()
endfunction()



function(___compile_expr_json)
  fread_data("${oocmake_base_dir}/resources/expr.json")
  ans(data)
  qm_serialize("${data}")
  ans(qm_data)
  
  return_ref(qm_data)
endfunction()




function(tick)

  if(___ticking)
    _return()
  endif()
  set(___ticking true)
  map_set(globaltick n 0)
  function(tick)
  if(___ticking)
    _return()
  endif()
  set(___ticking true)
  map_set(globaltick val true)
  map_tryget(globaltick n)
  ans(n)
  math(EXPR n "${n} + 1")
  math(EXPR res "${n} % 600")
  math(EXPR donottick "${n} % 10")
  if(donottick STREQUAL 0)
    echo_append(".")
  endif()

  if("${res}" STREQUAL 0)
    _message("")
    set(n 0)
  endif()
  map_set(globaltick n "${n}")


  endfunction()
  tick()
endfunction()





  
  function(message_indent msg) 
    message_indent_get()
    ans(indent)
    _message("${indent}${msg}")
  endfunction()







function(message_indent_pop)
  map_pop_back(global message_indent_level)
  ans(old_level)
  message_indent_level()
  ans(current_level)
  return_ref(current_level)
endfunction()





## commandline_args_get([--no-script])-> <string...>
## 
## returns the command line arguments with which cmake 
## was without the executable
##
## --no-script flag removes the script file from the command line args
##
## Example:
## command line: 'cmake -P myscript.cmake a s d'
## commandline_args_get() -> -P;myscript;a;s;d
## commandline_args_get(--no-script) -> a;s;d

function(commandline_args_get)
  set(args ${ARGN})
  list_extract_flag(args --no-script)
  ans(no_script)
  commandline_get()
  ans(args)
  # remove executable
  list_pop_front(args)
  if(no_script)
    list_extract_labelled_value(args -P)
  endif()
  return_ref(args)
endfunction()





  function(ascii_char code)
    ascii_generate_table()
    map_tryget(ascii_table "${code}")
    return_ans()
  endfunction()

 ## faster version
  function(ascii_char code)
    string(ASCII "${code}" res)
    return_ref(res)
  endfunction()





  # input:
  # {
  #  <path:<executable>>, // path to executable or executable name -> shoudl be renamed to command
  #  <args:<arg ...>>,        // command line arguments to executable, use string_semicolon_encode() on an argument if you want to pass an argument with semicolons
  #  <?timeout:<seconds>],            // timout
  #  <?cwd:<unqualified path>>,                // current working dir (default is whatever pwd returns)
  #
  # }
  # returns:
  # {
  #   path: ...,
  #   args: ...,
  #   <timeout:<seconds>> ...,
  #   <cwd:<qualified path>> ...,
  #   output: <string>,   // all output of the process (stderr, and stdout)
  #   result: <int>       // return code of the process (normally 0 indicates success)
  # }
  #
  #
  function(execute)
    process_start_info(${ARGN})
    ans(processStart)

    if(NOT processStart)
      return()
    endif()

    #obj("${processStart}")
  
    map_clone_deep(${processStart})
    ans(processResult)

    scope_import_map(${processStart})

    set(timeout TIMEOUT ${timeout})
    set(cwd WORKING_DIRECTORY "${cwd}")


    command_line_args_combine(${args})
    ans(arg_string)
    
    ## todo - test this
    string(REPLACE \\ \\\\ arg_string "${arg_string}")

    set(execute_process_command "
        execute_process(
          COMMAND \"\${command}\" ${arg_string}
          \${timeout}
          \${cwd}
          RESULT_VARIABLE result
          OUTPUT_VARIABLE output
          ERROR_VARIABLE output
        )

        map_set(\${processResult} output \"\${output}\")
        map_set(\${processResult} stdout \"\${output}\")
        map_set(\${processResult} result \"\${result}\")
        map_set(\${processResult} error \"\${result}\")
        map_set(\${processResult} return_code \"\${result}\")
    ")


     
    eval("${execute_process_command}")


    if(OOCMAKE_DEBUG_EXECUTE)
      json_print(${processResult})
    endif()

    return(${processResult})
  endfunction()





# pushes the specified vars to the parent scope
macro(vars_elevate)
  set(args ${ARGN})
  foreach(arg ${args})
    set("${arg}" ${${arg}} PARENT_SCOPE)
  endforeach()
endmacro()






#returns a value 
# expects a variable called result to exist in function signature
# may only be used inside functions
macro(return_value)
  if(NOT result)
    message(FATAL_ERROR "expected a variable called result to exist in function")
    return()
  endif()
  set(${result} ${ARGN} PARENT_SCOPE)
  return(${ARGN})
endmacro()





macro(yield_return)
    return(${__yield_tmp})
endmacro()





# extracts the specified values from the command line (see list extract)
# returns the rest of the command line
# the first three arguments of commandline_get are cmake command, -P, script file 
# these are ignored
function(commandline_extract)
  commandline_get()
  ans(args)
  list_extract(args cmd p script ${ARGN})
  ans(res)
  vars_elevate(${ARGN})
  set(res ${cmd} ${p} ${script} ${res})
  return_ref(res)
endfunction()






function(global_config key)
  map_get(global "${key}")
  ans(res)
  set("${key}" "${res}" PARENT_SCOPE)
  return_ref(res)
endfunction()




## takes a <command line~> or <process start info~>
## and returns a valid  process start info
function(process_start_info)
  set(__args ${ARGN})

  list_extract_labelled_value(__args TIMEOUT)
  ans(timeout_arg)

  list_extract_labelled_value(__args WORKING_DIRECTORY)
  ans(cwd_arg)

  if("${ARGN}_" STREQUAL "_")
    return()
  endif()


  obj("${ARGN}")
  ans(obj)

  if(NOT obj)
    command_line(${__args})
    ans(obj)
  endif()


  if(NOT obj)
    message(FATAL_ERROR "invalid process start info ${ARGN}")
  endif()

  set(path)
  set(cwd)
  set(command)
  set(args)
  set(parameters)
  set(timeout)
  set(arg_string)
  set(command_string)

  scope_import_map(${obj})

  if("${args}_" STREQUAL "_")
    set(args ${parameters})
  endif()

  if("${command}_" STREQUAL "_")
    set(command "${path}")
    if("${command}_" STREQUAL "_")
      message(FATAL_ERROR "invalid <process start info> missing command property")
    endif()
  endif()

  if(timeout_arg)
    set(timeout "${timeout_arg}")
  endif()

  if("${timeout}_" STREQUAL "_" )
    set(timeout -1)
  endif()




  if(cwd_arg)
    set(cwd "${cwd_arg}")
  endif()

  path("${cwd}")
  ans(cwd)

  if(EXISTS "${cwd}")
    if(NOT IS_DIRECTORY "${cwd}")
      message(FATAL_ERROR "specified working directory path is a file not a directory: '${cwd}'")
    endif()
  else()
    message(FATAL_ERROR "specified workind directory path does not exist : '${cwd}'")
  endif()



  # create a map from the normalized input vars
  map_capture_new(command args cwd timeout)
  return_ans()

endfunction()





#creates a unique id
function(make_guid out_id)
  string(RANDOM LENGTH 10 id)
  set(${out_id} ${id} PARENT_SCOPE)
endfunction()





# retruns the larger of the two values
function(math_max a b)
  if(${a} GREATER ${b})
    return(${a})
  else()
    return(${b})
  endif() 
endfunction()




 function(expr_string_parse str)
  set(regex_single_quote_string "'[^']*'")
  set(regex_double_quote_string "\"[^\"]*\"")
  if("${str}" MATCHES "^${regex_single_quote_string}$")
    string_slice("${str}" 1 -2)
    return_ans()
  endif()
  if("${str}" MATCHES "^(${regex_double_quote_string})$")
    string_slice("${str}" 1 -2)
    return_ans()
  endif()
  return()
endfunction()




## encodes a string to uri format 
## if you can pass decimal character codes  which are encoded 
## if you do not pass any codes  the characters  recommended by rfc2396
## are encoded
function(uri_encode str ) 

  if(NOT ARGN)
    uri_recommended_to_escape()
    ans(codes)
    list(APPEND codes)
  else()
    set(codes ${ARGN})
  endif()

  foreach(code ${codes})
    string(ASCII "${code}" char)
    dec2hex("${code}")
    ans(hex)
    # pad with zero
    if("${code}" LESS  16)
      set(hex "0${hex}")
    endif()

    string(REPLACE "${char}" "%${hex}" str "${str}" )
  endforeach()

  return_ref(str)
endfunction()






macro( return_if_run_before id)
	#string(MAKE_C_IDENTIFIER ${id} guard)
	string_normalize( "{id}")
  ans(guard)
	get_property(was_run GLOBAL PROPERTY ${guard})
	if(was_run)
		return()
	endif()
	set_property(GLOBAL PROPERTY ${guard} true)
endmacro()





function(expr_navigate_isvalid path)
  set(regex_identifier "[a-zA-Z0-9-_]+")
  set(regex_navigation_expr ".*\\.${regex_identifier}")
  if("${path}" MATCHES "^${regex_navigation_expr}$")
    return(true)
  endif()  
  return(false)   
endfunction()





  function(expr_navigate path)
    string_split_at_last(path nav "${path}" ".")
   # message("expr_nav path: ${path}, nav ${nav}")
    expr("${path}")
    ans(res)
    map_isvalid("${res}" )
    ans(ismap)
    if(NOT ismap)
      return()
    endif()

    map_get(${res}  "${nav}")
    ans(res)
    return_ref(res)
  endfunction()





  function(expr_function str)
    if(COMMAND "${str}")
      return_ref(str)
    endif()

    is_function(isfunc "${str}")
    if(isfunc)
      function_new(trash)
      ans(func)
      function_import("${str}" as "${func}")
      return_ref(func)
    endif()

    lambda_isvalid("${str}")
    ans(is_lambda)
    if(is_lambda)
      function_new(trash)
      ans(func)
      lambda_import("${str}" "${func}")
      return_ref(func)
    endif()
    return()
  endfunction()





  function(expr_integer_isvalid str)
  set(regex_integer "-?(0|([1-9][0-9]*))")
    if("${str}" MATCHES "^${regex_integer}$")
      return(true)
    endif()
    return(false)
  endfunction()







  function(expr_indexer_isvalid path)
    set(regex_indexer_expr ".*\\[.+\\]")
    if("${path}" MATCHES "^${regex_indexer_expr}$")
      return(true)
    endif()
    return(false)
  endfunction()





function(expr_string_isvalid str)

  set(regex_single_quote_string "'[^']*'")
  set(regex_double_quote_string "\"[^\"]*\"")
  set(regex_string "(${regex_single_quote_string}|${regex_double_quote_string})")
  if("${str}" MATCHES "^${regex_single_quote_string}$")
   return(true)
  endif()
  if("${str}" MATCHES "^(${regex_double_quote_string})$")
    return(true)
  endif()
  return(false)
endfunction()




function(expr_assignment_isvalid str)
    set(regex_single_quote_string "'[^']*'")
    set(regex_double_quote_string "\"[^\"]*\"")
    set(regex_string "((${regex_single_quote_string})|(${regex_double_quote_string}))")
    
    string(REGEX REPLACE "${regex_string}|[^=]" "" res "${str}")
    if(res)
      return(true)
    endif()
    return(false)
  endfunction()






  function(expr_assignment str scope)
    set(regex_single_quote_string "'[^']*'")
    set(regex_double_quote_string "\"[^\"]*\"")
    set(regex_string "((${regex_single_quote_string})|(${regex_double_quote_string}))")
    
    string(REGEX MATCHALL "(${regex_string}|[^=]+|=)" matches "${str}")

    set(lvalues)
    set(rvalues)

    foreach(match ${matches})     
      string(STRIP "${match}" match) 
      if("${match}" STREQUAL "=" )
        list(APPEND lvalues ${rvalues})
        set(rvalues)
      endif()
      list(APPEND rvalues "${match}")
    endforeach()
    
    list(REMOVE_ITEM lvalues =)
    list(REMOVE_ITEM rvalues =)

    expr("${rvalues}")

    ans(rvalue)

    message("lvalues ${lvalues}")
    message("rvalues ${rvalues} => ${rvalue}")


    foreach(lvalue ${lvalues})
      expr_assign_lvalue("${lvalue}" "${rvalue}" ${scope})
    endforeach()
    
  endfunction()





  function(expr_call str)    
    string(REPLACE ";" "†" str "${str}")

    string_nested_split("${str}" "\(" "\)")
    ans(parts)
#message("parts ${parts}")
    foreach(part ${parts})
      set(last_part "${part}")
     # message("${part}")
    endforeach()
    list_get(parts -2)
    ans(caller)
 #   message("caller ${caller}")
    string_slice("${caller}" 1 -2)

    ans(arguments)
    string(REPLACE "†" ";" arguments "${arguments}")
    set(evaluated_arguments)
    foreach(argument ${arguments})
      expr("${argument}")
      ans(evaluated_argument)
      set(evaluated_arguments "${evaluated_arguments}†${evaluated_argument}‡")
      
    endforeach()

    string_remove_ending("${str}" "${caller}")
    ans(path)
   # message("path ${path}")
    expr("${path}")
    ans(evaluated_path)
    
    string(REPLACE "‡†" "\" \"" evaluated_arguments "${evaluated_arguments}")
    string(REPLACE "‡" "\"" evaluated_arguments "${evaluated_arguments}")
    string(REPLACE "†" "\"" evaluated_arguments "${evaluated_arguments}")
    #message("evaled path ${evaluated_path}")
   # message("args ${arguments} -> ${evaluated_arguments}")

    set(call_statement "${evaluated_path}(${evaluated_arguments})")
   # message("${call_statement}")
   set_ans("")
    eval("${call_statement}")
    return_ans()
  endfunction()




 function(expr_string_parse str)
  set(regex_single_quote_string "'[^']*'")
  set(regex_double_quote_string "\"[^\"]*\"")
  if("${str}" MATCHES "^${regex_single_quote_string}$")
    string_slice("${str}" 1 -2)
    return_ans()
  endif()
  if("${str}" MATCHES "^(${regex_double_quote_string})$")
    string_slice("${str}" 1 -2)
    return_ans()
  endif()
  return()
endfunction()




  # evaluates a oo-cmake expression
  function(expr )
    return_reset()

    set(expressions ${ARGN})

    list(LENGTH expressions len)
    if(${len} EQUAL 0)
     return()
    endif()


    # multiple expressions
    if(${len} GREATER 1)
      set(result)
      foreach(part ${expressions})
        expr("${part}")
        ans(res)
        list(APPEND result "${res}")
      endforeach()
      return_ref(result)
    endif()

    set(expr "${expressions}")

   # string_nested_split("${expr}" { })
    #ans(parts)

    # empty expression
    #list(LENGTH parts len)
    #if(${len} EQUAL 0)
     # return()
    #endif()


    # single expreession
  #  message("single expr: ${expr}")
    string(STRIP "${expr}" expr)

    #exression is string
    expr_string_isvalid("${expr}")
    ans(is_string)
    if(is_string)
      #message("isstring")
      expr_string_parse("${expr}")
      return_ans()
    endif()

    expr_integer_isvalid("${expr}")
    ans(is_integer)
    if(is_integer)
      return_ref(expr)
    endif()

    string_char_at( 0 "${expr}" )
    ans(first_char)
    if("${first_char}" STREQUAL "*")
      string_slice("${expr}" 1 -1)
      ans(ref)
      ref_get(${ref})
      ans(val)
      return_ans()
    endif()



    expr_navigate_isvalid("${expr}")
    ans(is_navigation)
    if(is_navigation)
      #message("is navigation ${expr}")
      expr_navigate("${expr}")
      return_ans()
    endif()

    expr_indexer_isvalid("${expr}")
    ans(is_indexer)
    if(is_indexer)
     # message("is_indexer ${expr}")
      expr_indexer("${expr}")
      return_ans()
    endif()

    expr_call_isvalid("${expr}")
    ans(iscall)
    if(iscall)
      expr_call("${expr}")
      return_ans()
    endif()

    expr_function_isvalid("${expr}")
    ans(isfunction)
    if(isfunction)
      expr_function("${expr}")
      return_ans()
    endif()

    if(DEFINED "${expr}")
      return_ref("${expr}")
    endif()


   return()


  endfunction()





  function(expr_function_isvalid str)
    if(COMMAND "${str}")
        return(true)
    endif()
    is_function(is_function "${str}")
    if(is_function)
      return(true)
    endif()
    lambda_isvalid("${str}")
    ans(is_lambda)
    if(is_lambda)
      return(true)
    endif()  
    return(false)
  endfunction()





function(expr_indexer path)
  #message("indexer and stuff ${path}")
  string_nested_split("${path}" "["  "]")
  ans(parts)
 # message("parts ${parts}")
  list_get("parts" "-2")
  ans(indexer)
 # message("got indexer :${indexer}")
#return()
  string_remove_ending("${path}" "${indexer}")
  ans(path)

#  message("indexer ${indexer}")
  #message("${path}")

  expr("${path}")
  ans(data)

  string_slice("${indexer}" 1 -2)
  ans(index_expr)

  expr("${index_expr}")
  ans(index)

 # message("data: ${data}")
 # message("index_expr: ${index_expr}")
 # message("index :${index}")

  #integer indexation
  expr_integer_isvalid("${index}")
  ans(is_int)
  if(is_int)
    # expect data to be a list or a map
    map_isvalid("${data}" )
    ans(ismap)
    if(ismap)
      map_keys(${data} )
      ans(keys)
      list_get(keys "${index}")
      ans(key)
      map_get(${data}  ${key})
      ans(res)
      return_ref(res)
    endif()
    ref_isvalid("${data}")
    ans(isref)
    if(isref)
      #deref ref
      ref_get(${data})
      ans(data)
    endif()
    # data is list
    list_get(data "${index}")
    return_ans()
  endif()

  # string indexation needs map
  map_isvalid("${data}" )
  ans(ismap)
  if(NOT ismap)
    return()
  endif()

  #return nothing if map does not have key
  map_has(${data}  "${index}")
  ans(haskey)
  if(NOT haskey)
    return()
  endif()

  map_get(${data}  ${index} )
  ans(result)
  return_ref(result)

endfunction()




#‡†
  function(expr_assign_lvalue lvalue rvalue scope)
    message("assigning ${lvalue} = ${rvalue}")

    set(regex_identifier "[a-zA-Z0-9-_]+")

    string(REPLACE ";" "†" lvalue "${lvalue}")
    

    if(NOT "${first_char}"  STREQUAL "[")
      set(lvalue ".${lvalue}")
    endif()


    string_nested_split("${lvalue}" "[" "]")
    ans(splits)
    message("splits ${splits}")
    set(lvalue)


    foreach(split ${splits})
      if("${split}" MATCHES "^\\[.+\\]$")
        string_slice("${split}" 1 -2)
        ans(inner_split)
        expr("${inner_split}")
        ans(split)
        set(split "[${split}]")
      endif()
      list(APPEND lvalue "${split}")
    endforeach()
    string(REPLACE ";" "" lvalue "${lvalue}")
    string(REPLACE "†" ";" lvalue "${lvalue}")
    string(REPLACE "." ";" lvalue "${lvalue}")
    string(REPLACE "[" ";" lvalue "${lvalue}")
    string(REPLACE "]" "" lvalue "${lvalue}") 


   # string(REGEX REPLACE "")
    message("lvalue transformed: ${lvalue}")

    set(current_scope ${scope})
    set(last_scope)
    set(path ${lvalue})
    set(current_index)
    set(last_index)
    while(true)
      set(next_scope)
      set(last_index ${current_index})
      list_pop_front( path )  
      ans(current_index)
      list_isempty(path)
      ans(is_done)

      
      map_isvalid(${current_scope})
      ans(is_map)

      ref_isvalid(${current_scope})
      ans(is_ref)
      

      expr_integer_isvalid("${current_index}")
      ans(is_int_index)

      message("current index: ${current_index}")
      message("rest:${path}")
      message("int index:${is_int_index}")
      message("is_done ${is_done}")
      message("is_map ${is_map}")
      message("is_ref ${is_ref}\n")


      
      if(is_map)
        if(is_int_index)
          map_keys(${current_scope} )
          ans(keys)
          list_get(keys "${current_index}")
          ans(current_index)
        endif()
        if(NOT current_index)
          # invalid key
          message(FATAL_ERROR "invalid key '${current_index}'")
          return()
        endif()
        # index now is a string index in all cases

        if(is_done)
          map_set(${current_scope} "${current_index}" "${rvalue}")
          return_ref(rvalue)
          # finished setting value
        endif()
        # navigate
        map_tryget(${current_scope}  "${current_index}")
        ans(next_scope)
        if(NOT next_scope)
          map_new()
          ans(next_scope)
          map_set(${current_scope} "${current_index}" ${next_scope})
        endif()

        # next_scope exists

      elseif(is_ref)
        if(is_done)
          ref_set(${current_scope} ${rvalue})
          return_ref(rvalue)
          # finished setting value
        endif()

        if(NOT is_int_index)
          message(FATAL_ERROR "can only set string indices on maps")
          return()
        endif()

        message(FATAL_ERROR "not iplemented for ref currently") 


      else()
        message("just a var")
        if(is_done)
          if(NOT is_int_index)
              message(FATAL_ERROR "cannot set string index for a cmake list")
          endif()
          map_get(${last_scope}  ${last_index})
          ans(last_value)
          list_set_at(last_value ${current_index} "${rvalue}")
          ans(success)
          if(NOT success)
            message(FATAL_ERROR "cannot set ${current_index} because it is invalid for list")
          endif()
          map_set(${last_scope} ${last_index} "${last_value}")
        endif()
      endif()


      set(last_scope ${current_scope})
      set(current_scope ${next_scope})

      if(is_done)
        break()
      endif()
    endwhile()

    return()
  endfunction()





  function(expr_call_isvalid str)

    if("${str}" MATCHES "^.*\\(.*\\)$")
      return(true)
    endif()
    return(false)
  endfunction()





#prints result
function(print_result result)
  list(LENGTH argc "${result}" )
  if("${argc}" LESS 2)
    message("${result}")
  else()
    foreach(arg ${result})
      message("${arg}")
    endforeach()
  endif()
endfunction()






# prints the variables name and value as a STATUS message
macro(print_var varname)
  message(STATUS "${varname}: ${${varname}}")
endmacro()






function(print_call_counts)
	get_property(props GLOBAL PROPERTY "function_calls")
	set(countfunc "(current) return_truth(\${current} STREQUAL \${it})")
	foreach(prop ${props})
		get_property(call_count GLOBAL PROPERTY "call_count_${prop}")
		get_property(callers GLOBAL PROPERTY "call_count_${prop}_caller")


		message("${prop}: ${call_count}")
	endforeach()
endfunction()





function(print_function func)
	function_lines_get( "${func}")
  ans(lines)
	set(i "0")
	foreach(line ${lines})		
		message(STATUS "LINE ${i}: ${line}")
		math(EXPR i "${i} + 1")
	endforeach()
endfunction()





macro(print_locals)

get_cmake_property(_variableNames VARIABLES)
foreach (_variableName ${_variableNames})
    message(STATUS "${_variableName}=${${_variableName}}")
endforeach()

endmacro()




## prints the specified variables names and their values in a single line
## e.g.
## set(varA 1)
## set(varB abc)
## print_vars(varA varB)
## output:
##  varA: '1' varB: 'abc'
  function(print_vars)
    set(__str)
    foreach(arg ${ARGN})
      assign(____cur = ${arg})
      json_serialize("${____cur}")
      ans(____cur)
      string_shorten("${____cur}" "300")
      ans(____cur)
      set(__str "${__str} ${arg}: ${____cur}")

    endforeach()
    message("${__str}")
  endfunction()




function(print_macros)
get_cmake_property(_variableNames MACROS)
foreach (_variableName ${_variableNames})
    message(STATUS "${_variableName}")
endforeach()
endfunction()




function(performance_init)
  map_new()
  ans(perfmap)
  map_set(global __performance ${perfmap})

  function(performance_init)
      
  endfunction()

endfunction()

function(performance_sample file line)
  
  map_get(global __performance)

endfunction()

function(performance_report)

endfunction()




function(print_commands)

get_cmake_property(_variableNames COMMANDS)
foreach (_variableName ${_variableNames})
    message(STATUS "${_variableName}")
endforeach()

endfunction()




# creates a breakpoint 
# usage: breakpoint(${CMAKE_CURRENT_LIST_FILE} ${CMAKE_CURRENT_LIST_LINE})
function(breakpoint file line) 
  if(NOT DEBUG_CMAKE)
    return()
  endif()
  message("breakpoint reached ${file}:${line}")
  while(1)
    echo_append("> ")
    read_line()
    ans(cmd)
    if("${cmd}" STREQUAL "")
      message("continuing execution")
      break()
    endif()

    
    if("${cmd}" MATCHES "^\\$.*")
      string(SUBSTRING "${cmd}" 1 -1 var)
      

      get_cmake_property(_variableNames VARIABLES)
      foreach(v ${_variableNames})
        if("${v}" MATCHES "${cmd}")
          dbg("${v}")

        endif()
      endforeach()

    endif()
    



  endwhile()
endfunction()






function(stack_pop stack)
  map_tryget("${stack}" back)
  ans(current_index)
  if(NOT current_index)
    return()
  endif()
  map_tryget("${stack}" "${current_index}")
  ans(res)
  math(EXPR current_index "${current_index} - 1")
  map_set_hidden("${stack}" back "${current_index}")
  return_ref(res)
endfunction()





function(rlist_new)
    ref_new(rlist)
    ans(rlist)
    map_set_hidden(${queue} front 0)
    map_set_hidden(${queue} back 0)
    return(${queue})
endfunction()







# returns the specified element of the stack
function(stack_at stack idx)
  map_tryget("${stack}" back)
  ans(current_index)
  math(EXPR idx "${idx} + 1")
  if("${current_index}" LESS "${idx}")
    return()
  endif()
  map_tryget("${stack}" "${idx}")
  return_ans()
endfunction()





  function(stack_new)
    ref_new(stack)
    ans(stack)   
    map_set_hidden("${stack}" front 0)
    map_set_hidden("${stack}" back 0)
    return(${stack})
  endfunction()




function(stack_push stack)
  map_tryget("${stack}" back)
  ans(current_index)
  
  # increase stack pointer
  if(NOT current_index)
    set(current_index 0)
  endif()
  math(EXPR current_index "${current_index} + 1")
  map_set_hidden("${stack}" back "${current_index}")

  map_set_hidden("${stack}" "${current_index}" "${ARGN}")
endfunction()






  function(queue_new)
    ref_new(queue)
    ans(queue)
    map_set_hidden(${queue} front 0)
    map_set_hidden(${queue} back 0)
    return(${queue})
  endfunction()





  function(queue_peek queue)
    map_tryget("${queue}" front)
    ans(front)
    map_tryget("${queue}" back)
    ans(back)
    if(${front} LESS ${back} )
      map_tryget("${queue}" "${front}")
      return_ans()
    endif()
    return()
  endfunction()






# returns all elements of the stack possibly fucking up
# element count because single elements may be lists-
# -> lists are flattened
function(stack_enumerate stack)
  map_tryget("${stack}" back)
  ans(current_index)
  if(NOT current_index)
    return()
  endif()
  
 # math(EXPR current_index "${current_index} - 1")
  set(res)
  foreach(i RANGE 1 ${current_index})
    map_tryget("${stack}" "${i}")
    ans(current)
    list(APPEND res "${current}")
  endforeach()
  return_ref(res)
endfunction()




function(queue_isempty stack)
  map_tryget("${stack}" front)
  ans(front)
  map_tryget("${stack}" back)
  ans(back)
  math(EXPR res "${back} - ${front}")
  if(res)
    return(false)
  endif()  
  return(true)
endfunction()





  function(stack_peek stack)
    map_tryget("${stack}" back)
    ans(back)
    map_tryget("${stack}" "${back}")
    return_ans()
  endfunction()





  function(queue_push queue)
    map_tryget("${queue}" back)
    ans(back)
    map_set_hidden("${queue}" "${back}" "${ARGN}")
    math(EXPR back "${back} + 1")
    map_set_hidden("${queue}" back "${back}")
    
  endfunction()






  function(stack_isempty stack)
    map_tryget("${stack}" back)
    ans(count)
    if(count)
      return(false)
    endif()
    return(true)
  endfunction()





function(queue_pop queue)
  map_tryget("${queue}" front)
  ans(front)
  map_tryget("${queue}" back)
  ans(back)

  if(${front} LESS ${back})
    map_tryget("${queue}" "${front}")
    ans(res)
    math(EXPR front "${front} + 1")
    map_set_hidden("${queue}" "front" "${front}")
    return_ref(res)
  endif()
  return()
 endfunction()





function(navigation_expression_parse)
    string(REPLACE "." ";" expression "${ARGN}")
    string(REPLACE "[" "<" expression "${expression}" )
    string(REPLACE "]" ">" expression "${expression}" )
    string(REGEX REPLACE "([<>][0-9:]*[<>])" ";\\1" expression "${expression}")
    string(REGEX REPLACE "^;" "" expression "${expression}")
    return_ref(expression)
  endfunction()




## assign([!]<expr> <value>|("="|"+=" <expr><call>)) -> <any>
##
## the assign function allows the user to perform some nonetrivial 
## operations that other programming languages allow 
##
## Examples
## 
  function(assign __lvalue __operation __rvalue)    
    ## is a __value

    if(NOT "${__operation}" MATCHES "^(=|\\+=)$" )
      ## if no equals sign is present then interpret all
      ## args as a simple literal cmake value
      ## this allows the user to set an expression to 
      ## a complicated string with spaces without needing
      ## to single quote it
      set(__value ${__operation} ${__rvalue} ${ARGN})
    elseif("${__rvalue}" MATCHES "^'.*'$")
      string_decode_delimited("${__rvalue}" ')
      ans(__value)
    elseif("${__rvalue}" MATCHES "(^{.*}$)|(^\\[.*\\]$)")
      script("${__rvalue}")
      ans(__value)
    else()
      navigation_expression_parse("${__rvalue}")
      ans(__rvalue)
      list_pop_front(__rvalue)
      ans(__ref)

      if("${ARGN}" MATCHES "^\\(.*\\)$")
        ref_nav_get("${${__ref}}" "&${__rvalue}")
        ans(__value)

        map_tryget(${__value} ref)
        ans(__value_ref)

        data("${ARGN}")
        ans(__args)
        if(NOT __value_ref)
          call("${__ref}" ${__args})
          ans(__value)
      
        else()
          map_tryget(${__value} property)
          ans(__prop)
          map_tryget(${__value} range)
          ans(ranges)

          if(NOT ranges)
            list_pop_front(__args)
            list_pop_back(__args)
            obj_member_call("${__value_ref}" "${__prop}" ${__args})
            ans(__value)

          else()
            map_tryget(${__value} __value)
            ans(__callables)
            set(__value)
            set(this "${__value_ref}")
            foreach(__callable ${__callables})
              call("${__callable}" ${__args})
              ans(__res)
              list(APPEND __value ${__res})
            endforeach()
          endif()
        endif()
      else()      
        ref_nav_get("${${__ref}}" ${__rvalue})
        ans(__value)
      endif()
    endif()
    string_take(__lvalue !)
    ans(__exc)
    navigation_expression_parse("${__lvalue}")
    ans(__lvalue)
    list_pop_front(__lvalue)
    ans(__lvalue_ref)

    if("${__operation}" STREQUAL "+=")
      ref_nav_get("${${__lvalue_ref}}" "${__lvalue}")
      ans(prev_value)
      set(__value "${prev_value}${__value}")
    endif()
   # message("ref_nav_set ${${__lvalue_ref}} ${__exc}${__lvalue} ${__value}" )
    ref_nav_set("${${__lvalue_ref}}" "${__exc}${__lvalue}" "${__value}")
    ans(__value)
    set(${__lvalue_ref} ${__value} PARENT_SCOPE)
    return_ref(__value)
  endfunction()






  function(prompt_property prop)
    query_property(prompt_input "${prop}")
    return_ans()
  endfunction()





  function(define_test_function name parse_function_name)
    set(args ${ARGN})
    string_combine(" " ${args})
    ans(argstring)
    set(evaluated_arg_string)
    foreach(arg ${ARGN})
      set(evaluated_arg_string "${evaluated_arg_string} \"\${${arg}}\"")
    endforeach()
   # messagE("argstring ${argstring}")
   # message("evaluated_arg_string ${evaluated_arg_string}")
    eval("
      function(${name} expected ${argstring})
        set(args \${ARGN})
        list_extract_flag(args --print)
        ans(print)
        data(\"\${expected}\")
        ans(expected)
        #if(parsed)
        #  set(expected \${parsed})
        #endif()
        #if(NOT expected)
        #  message(FATAL_ERROR \"invalid expected value\")
        #endif()
        ${parse_function_name}(${evaluated_arg_string} \${args})
        ans(uut)

        if(print)
          json_print(\${uut})
        endif()


        
        map_match(\"\${uut}\" \"\${expected}\")
        ans(res)
        if(NOT res)
          echo_append(\"actual: \")
          json_print(\${uut})
          echo_append(\"expected: \")
          json_print(\${expected})
        endif()
        assert(res MESSAGE \"values do not match\")
      endfunction()

    ")
    return()
  endfunction()






  function(prompt_input)
    echo_append("> ")
    read_line()
    ans(res)
    return_ref(res)
  endfunction()







  ## queries a property
  function(query_property input_callback property)
    property_def("${property}")
    ans(property)
    map_tryget(${property} "display_name")
    ans(display_name)
    map_tryget(${property} "property_type")
    ans(property_type)
    type_def("${property_type}")
    ans(property_type)
    map_tryget(${property_type} type_name)
    ans(property_type_name)
    message("enter ${display_name} (${property_type_name})")
    query_type("${input_callback}" "${property_type}")
    ans(res)
    return_ref(res)
  endfunction()

  







  function(query_properties input_callback type)

    map_new()
    ans(res)

    message_indent_push()
    foreach(property ${properties})
      property_def("${property}")
      ans(property)
      query_property("${input_callback}" "${property}")
      ans(value)
      map_tryget(${property} property_name)
      ans(prop_name)
      map_set(${res} "${prop_name}" "${value}")
    endforeach()
    message_indent_pop()
    return_ref(res)
  endfunction()







function(regex_escaped_string delimiter_begin delimiter_end)

  set(regex "${delimiter_begin}(([^${delimiter_end}\\]|([\\][${delimiter_end}])|([\\][\\])|([\\]))*)${delimiter_end}")
  return_ref(regex)
endfunction()





## returns the regex for a delimited string 
## allows escaping delimiter with '\' backslash
function(regex_delimited_string)
  set(delimiters ${ARGN})


  if("${delimiters}_" STREQUAL "_")
    set(delimiters \")
  endif()



  list_pop_front(delimiters)
  ans(delimiter_begin)


  if("${delimiter_begin}" MATCHES ..)
    string(REGEX REPLACE "(.)(.)" "\\2" delimiter_end "${delimiter_begin}")
    string(REGEX REPLACE "(.)(.)" "\\1" delimiter_begin "${delimiter_begin}")
  else()
    list_pop_front(delimiters)
    ans(delimiter_end)
  endif()

  
  if("${delimiter_end}_" STREQUAL "_")
    set(delimiter_end "${delimiter_begin}")
  endif()
  #set(regex "${delimiter_begin}(([^${delimiter_end}])*)${delimiter_end}")
  set(delimiter_end "${delimiter_end}" PARENT_SCOPE)
  #set(regex "${delimiter_begin}(([^${delimiter_end}\\]|(\\[${delimiter_end}])|\\\\)*)${delimiter_end}")
  regex_escaped_string("${delimiter_begin}" "${delimiter_end}")
  ans(regex)
  return_ref(regex)
endfunction()






# contains common regular expression 
macro(regex_uri)

    set(lowalpha "[a-z]")
    set(upalpha "[A-Z]")
    set(digit "[0-9]")
    set(alpha "(${lowalpha}|${upalpha})")
    set(alphanum "(${alpha}|${digit})")

    set(reserved "[\;\\/\\?:@&=\\+\\$,]")
    set(reserved_no_slash "[\;\\?:@&=\\+\\$,]")
    set(mark "[\\-_\\.!~\\*'\\(\\)]")
    set(unreserved "(${alphanum}|${mark})")
    set(hex "[0-9A-Fa-f]")
    set(escaped "%${hex}${hex}")


    #set(uric "(${reserved}|${unreserved}|${escaped})")
    set(uric "[^ ]")
    set(uric_so_slash "${unreserved}|${reserved_no_slash}|${escaped}")


    set(scheme_regex "((${alpha})(${alpha}|${digit}|[\\+\\-\\.])*)")
    set(net_root_regex "//")
    set(abs_root_regex "/")

    set(abs_path "\\/${path_segments}")
    set(net_path "\\/\\/${authority}(${abs_path})?")
    
    set(authority_char "([^/\\?#])" )
    set(authority_regex "${authority_char}+")

    set(segment_char "[^\\?#/ ]")
    set(segment_separator_char "/")


    set(path_char_regex "[^\\?#]")
    set(query_char_regex "[^#]")
    set(query_regex "\\?${query_char_regex}*")
    set(fragment_char_regex "[^ ]")
    set(fragment_regex "#${fragment_char_regex}*")

#  ";" | ":" | "&" | "=" | "+" | "$" | "," 
    set(dns_user_info_char "(${unreserved}|${escaped}|[;:&=+$,])")
    set(dns_user_info_separator "@")
    set(dns_user_info_regex "(${dns_user_info_char}+)${dns_user_info_separator}")

    set(dns_port_seperator :)
    set(dns_port_regex "[0-9]+")
    set(dns_host_regex_char "[^:]")
    set(dns_host_regex "(${dns_host_regex_char}+)${dns_port_seperator}?")
      set(dns_domain_toplabel_regex "${alpha}(${alphanum}|\\-)*")
      set(dns_domain_label_separator "[.]")
    set(dns_domain_label_regex "[^.]+")
    set(ipv4_group_regex "(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])")
    set(ipv4_regex "${ipv4_group_regex}[\\.]${ipv4_group_regex}[\\.]${ipv4_group_regex}[\\.]${ipv4_group_regex}")
endmacro()





macro(http_regexes)
  #https://www.ietf.org/rfc/rfc2616
  set(http_version_regex "HTTP/[0-9]\\.[0-9]")
  set(http_header_regex "([a-zA-Z0-9_-]+): ([^\r]+)\r\n")
  set(http_headers_regex "(${http_header_regex})*")

  set(http_method_regex "GET|HEAD|POST|PUT|DELETE|TRACE|CONNECT")
  set(http_request_uri_regex "[^ ]+")
  set(http_request_line_regex "(${http_method_regex}) (${http_request_uri_regex}) (${http_version_regex})\r\n")
  set(http_request_header_regex "(${http_request_line_regex})(${http_headers_regex})")

  set(http_status_code "[0-9][0-9][0-9]")
  set(http_reason_phrase "[^\r]+")
  set(http_response_line_regex "(${http_version_regex}) (${http_status_code}) (${http_reason_phrase})\r\n")
  set(http_response_header_regex "(${http_response_line_regex})(${http_headers_regex})")
endmacro()




function(function_help result func)
	function_lines_get( "${func}")
	ans(res)
	set(res)
	foreach(line ${res})
		string(STRIP "${line}" line)
		if(line)
			string(SUBSTRING "${line}" 0 1 first_char)
			if(NOT ${first_char} STREQUAL "#")
				if(res)
					set(res "${res}\n")
				endif()
				set(res "${res}${line}")
			else()
				break()
			endif()
		endif()
	endforeach()
	return_value("${res}")
endfunction()




#returns true if the the val is a function string or a function file
function(is_function result val)

	is_function_string(is_func "${val}")
	if(is_func)
		return_value(string)
	endif()
	is_function_cmake(is_func "${val}")
	if(is_func)
		return_value(cmake)
	endif()
	
	if(is_function_called)
		return_value(false)
	endif()
	is_function_file(is_func "${val}")
	if(is_func)		
		return_value(file)
	endif()
	set(is_function_called true)
	is_function_ref(is_func "${val}")
	if(is_func)
		return_value(${is_func})
	endif()


	return_value(false)
endfunction()




# allows a single line call with result 
# ie rcall(some_result = obj.getSomeInfo(arg1 arg2))
function(rcall __rcall_result_name equals )
  set_ans("")
  call(${ARGN})
  ans(res)
  set(${__rcall_result_name} ${res} PARENT_SCOPE)
  return_ref(res)
endfunction()




## defines the function called ${function_name} to call an operating system specific function
## uses ${CMAKE_SYSTEM_NAME} to look for a function called ${function_name}${CMAKE_SYSTEM_NAME}
## if it exists it is wrapped itno ${function_name}
## else ${function_name} is defined to throw an error if it is called
function(wrap_platform_specific_function function_name)
  os()
  ans(os_name)
  set(specificname "${function_name}_${os_name}")
  if(NOT COMMAND "${specificname}")      
    eval("
    function(${function_name})
      message(FATAL_ERROR \"operation is not supported on ${os_name} - look at document of '${function_name}' and implement a function with a matching interface called '${specificname}' for you own system\")        
    endfunction()      
    ")
  else()
    eval("
      function(${function_name})
        ${function_name}_${os_name}(\${ARGN})
        return_ans()
      endfunction()
    ")
    
  endif()
  return()
endfunction()





# laternative to curry (just one string argument)
  function(curry2 str)
    string(REPLACE " "  ";" str "${str}")
    string(REPLACE ")"  ";);" str "${str}")
    string(REPLACE "("  ";(;" str "${str}")
    #string(REPLACE "\"" "\\\"" str "${str}")
    
    #message("curry2... '${str}'")
    #string(REPLACE "" "" str "${str}")

    curry(${str} ${ARGN})
    return_ans()
  endfunction()




# imports the specified map as a function table which is callable via <function_name>
# whis is a performance enhancement 
function(function_import_table map function_name)
  map_keys(${map} )
  ans(keys)
  set("ifs" "if(false)\n")
  foreach(key ${keys})
    map_get(${map}  ${key})
    ans(command_name)
    set(ifs "${ifs}elseif(\"${key}\" STREQUAL \"\${switch}\" )\n${command_name}(\"\${ARGN}\")\nreturn_ans()\n")
  endforeach()
  set(ifs "${ifs}endif()\n")
set("evl" "function(${function_name} switch)\n${ifs}\nreturn()\nendfunction()")
   # message(${evl})
  set_ans("")
   
    eval("${evl}")
endfunction()






# dynamic function call method
# can call the following
# * a cmake macro or function
# * a cmake file containing a single function
# * a lambda expression (see lambda())
# * a object with __call__ operation defined
# * a property reference ie this.method()
# CANNOT  call 
# * a navigation path
  # no output except through return values or referneces
  function(call __function_call_func __function_call_paren_open)

    return_reset()
    set(__function_call_args ${ARGN})

    list_pop_back( __function_call_args)
    ans(__function_call_paren_close)
    
    if(NOT "_${__function_call_paren_open}${__function_call_paren_close}" STREQUAL "_()")
      message(WARNING "expected opening and closing parentheses for function '${ARGN}'")
    endif()

    if(COMMAND "${__function_call_func}")
      set_ans("")
      eval("${__function_call_func}(\${__function_call_args})")
      return_ans()
    endif()

    if(DEFINED "${__function_call_func}")
      call("${${__function_call_func}}"(${__function_call_args}))
      return_ans()
    endif()

    ref_isvalid("${__function_call_func}")
    ans(isref)
    if(isref)
      obj_call("${__function_call_func}" ${__function_call_args})
      return_ans()
    endif()

    propref_isvalid("${__function_call_func}")
    ans(ispropref)
    if(ispropref)
      propref_get_key("${__function_call_func}")
      ans(key)
      propref_get_ref("${__function_call_func}")
      ans(ref)

      obj_member_call("${ref}" "${key}" ${__function_call_func})

    endif()



    lambda_isvalid("${__function_call_func}")      
    ans(is_lambda)
    if(is_lambda)
      lambda_import("${__function_call_func}" __function_call_import)
      __function_call_import(${__function_call_args})
      return_ans()
    endif()


    if(DEFINED "${__function_call_func}")
      call("${__function_call_func}"(${__function_call_args}))
      return_ans()
    endif()


    is_function(is_func "${__function_call_func}")
    if(is_func)
      function_import("${__function_call_func}" as __function_call_import REDEFINE)
      __function_call_import(${__function_call_args})
      return_ans()
    endif()

    if("${__function_call_func}" MATCHES "^[a-z0-9A-Z_-]+\\.[a-z0-9A-Z_-]+$")
      string_split_at_first(__left __right "${__function_call_func}" ".")
      ref_isvalid("${__left}")
      ans(__left_isref)
      if(__left_isref)
        obj_member_call("${__left}" "${__right}" ${__function_call_args})  
        return_ans()
      endif()
      ref_isvalid("${${__left}}")
      ans(__left_isrefref)
      if(__left_isrefref)
        obj_member_call("${${__left}}" "${__right}" ${__function_call_args})
        return_ans()
      endif()
    endif()

    nav(__function_call_import = "${__function_call_func}")
    if(__function_call_import)
         call("${__function_call_import}"(${__function_call_args}))
      return_ans()
    endif()

   message(FATAL_ERROR "tried to call a non-function:'${__function_call_func}'")
  endfunction()




function(is_function_file result function_file)
	path("${function_file}")
	ans(function_file)
	
	if(NOT EXISTS "${function_file}")
		return_value(false)
	endif()

	if(IS_DIRECTORY "${function_file}")
		return_value(false)
	endif()

	file(READ "${function_file}" input)
	if(NOT input)
		return_value(false)
	endif()
	#is_function_string(res ${input})
	is_function(res "${input}")
	
	return_value(${res})
endfunction()




function(is_function_ref result func)
	ref_isvalid("${func}" )
  ans(is_ref)
	if(NOT is_ref)
		return(false)
	endif()
	ref_get(${func} )
  ans(val)
	is_function(res "${val}")
	return_value(${res})
	
endfunction()





function(try_call)
  set(args ${ARGN})
  list_pop_front(args)
  ans(func)
  is_function(is_func "${func}")
  if(is_func)
    return()
  endif()
  call(${ARGN})
  return_ans()
endfunction()




 # curry a function
  # let funcA(a b c d) -> return("${a}${b}${c}${d}")
  # and curry(funcA(/2 33 /1 44) as funcB)
  # funcB(22 55) -> 55332244   
  function(curry func)
    set(args ${ARGN})
    list_extract_labelled_value(args as)
    ans(curried_function_name)

    if(NOT curried_function_name)
      function_new()
      ans(curried_function_name)
    endif()

    # remove parentheses
    list_pop_front( args)
    ans(paren_open)
    list_pop_back( args)
    ans(paren_close)

    set(arguments_string)
    set(call_string)

    set(bound_args)
    list(LENGTH args len)


    string_encode_bracket("${args}")
    ans(args)

    set(indices)
    foreach(arg ${args})
    
      if("${arg}" MATCHES "^/([0-9]+)$")
        # reorder argument
        set(arg "${CMAKE_MATCH_1}")
        list(APPEND indices "${arg}")
        set(arg_name "__arg_${arg}")
        set(call_string "${call_string} \"\${__arg_${arg}}\"")  
      else()
        # curry single argument
        cmake_string_escape("${arg}")
        ans(arg)
        string_decode_bracket("${arg}")
        ans(arg)
        set(call_string "${call_string} \"${arg}\"")  
      endif()

    endforeach()

    list(LENGTH indices len)
    if("${len}" GREATER 1)
      list(SORT indices)
    endif()

    foreach(arg ${indices})
      set(arguments_string "${arguments_string} __arg_${arg}")
    endforeach()
   # message("leftovers: ${leftovers}")

    # if func is not a command import it
    if(NOT COMMAND "${func}")
      function_new()
      ans(original_func)
      function_import("${func}" as ${original_func} REDEFINE)
    else()
      set(original_func "${func}")
    endif()

    set(evaluate
"function(${curried_function_name} ${arguments_string})${bound_args}
  ${original_func}(${call_string} \${ARGN})
  return_ans()
endfunction()")


   
   #message("curry: ${evaluate}")
    set_ans("")
    eval("${evaluate}")
    return_ref(curried_function_name)
  endfunction()





function(function_import_dispatcher function_name)
    string(REPLACE ";" "\n" content "${ARGN}")

    string(REGEX REPLACE "([^\n]+)" "elseif(command STREQUAL \"\\1\")\n \\1(\${ARGN})\nreturn_ans()\n" content "${content}")
    eval("
        function(${function_name} command)
          if(false)
          ${content}
            endif()
          return()
        endfunction()

      ")
      return()
endfunction()


function(function_import_global_dispatcher function_name)
    get_cmake_property(commands COMMANDS)       
    list(REMOVE_ITEM commands else if elseif endif while function endwhile endfunction macro endmacro foreach endforeach)
    function_import_dispatcher("${function_name}" ${commands})
    return()
endfunction()




function(function_string_import function_string)
  set_ans("")
  eval("${function_string}")
  return()
endfunction()





# injects code into  function (right after function is called) and returns result
function(function_string_rename input_function new_name) 
	function_string_get( "${input_function}")
	ans(function_string)
	function_signature_regex(regex)

	function_lines_get( "${input_function}")
	ans(lines)
	
	foreach(line ${lines})
		string(REGEX MATCH "${regex}" found "${line}")
		if(found)
			string(REGEX REPLACE "${regex}"  "\\1(${new_name} \\3)" new_line "${line}")
			string_replace_first("${line}" "${new_line}" "${input_function}")
			ans(input_function)
			break()
		endif()
	endforeach()
	return_ref(input_function)
endfunction()




#
function(function_signature_get func)
	function_lines_get( "${func}")
  ans(lines)
	#function_signature_regex(regex)
	foreach(line ${lines})
		string(REGEX MATCH "^[ ]*([mM][aA][cC][rR][oO]|[fF][uU][nN][cC][tT][iI][oO][nN])[ ]*\\([ \n\r]*([A-Za-z0-9_\\\\-]*)(.+)\\)" found "${line}")
		if(found)
      return_ref(line)
		endif()
	endforeach()
  return()
endfunction()




# reads a functions and returns it
function(load_function result file_name)	
	file(READ ${file_name} func)	
	set(${result} ${func} PARENT_SCOPE)
endfunction()





# creates a function from the lambda expressio in code.
# syntax for lambdas: (arg1 arg2 ... argn)->COMMAND;COMMAND;...
# if no return() is called lambda will return_ans() at the end 
# which returns whatever was returned last
# instead of ${var} syntax use $var for variables
# use {expr} for evaluating expressions
function(lambda_parse code)
  string(REPLACE "'" "\"" code "${code}")
  string(REPLACE ");" ")\n" code "${code}")

  string_replace_first("(" "function(lambda_func "  "${code}")
  ans(code)
  string_replace_first(")->" ")\nset(__ans)\n" "${code}")
  ans(code)
  string(REGEX MATCHALL "{[^}]*}" expressions "${code}")

  if(expressions)
    foreach(expression ${expressions})
      string(RANDOM  tmp_var_name)
      set(tmp_var_name "__tmp_var_${tmp_var_name}")
      
      string_slice("${expression}" 1 -2)
      ans(eval_this)
      set(eval_string "expr(\"${eval_this}\")\nans(${tmp_var_name})\n")
      string_regex_escape("${expression}")
      ans(expression)
      string_regex_escape("${eval_string}")
      ans(eval_string)
      string(REPLACE "\\" "\\\\" eval_string "${eval_string}")
      set(repl "\\1\n${eval_string}\\2\\\\\$${tmp_var_name}")
    #  message("replace ${repl}")
    #  message("expression '${expression}'")
      set(regex "(\n)([^\n]*)(${expression})")
      string(REGEX MATCH "${regex}" match "${code}")
     # message("match ${match}\n")
      string(REGEX REPLACE "${regex}" "${repl}" code "${code}")
    endforeach()
    string(REPLACE "\\." "." code "${code}")
    string(REPLACE "\\$" "$" code "${code}")
  endif()

    string(REGEX MATCHALL "(\\$[a-zA-Z0-9-_\\.]+)" matches "${code}")
    list(REMOVE_DUPLICATES matches)
    foreach(match ${matches})
      string(REPLACE "$" "\${" repl "${match}")
      set(repl "${repl}}")
      string(REPLACE "${match}" "${repl}" code "${code}")
    endforeach()
    set(code "${code}\nreturn_ans()\nendfunction()")
    return_ref(code)
  endfunction()




  # returns true if given code is a valid lambda expression
  function(lambda_isvalid code)
    string_split_at_first(lambda_signature partB "${code}" "->")
   # message("signature ${lambda_signature}")
    string(STRIP "${lambda_signature}" lambda_signature)
    string_ends_with("${lambda_signature}" ")")
    ans(ok)
    if(NOT ok)
      return(false)
  endif()
    string_starts_with("${lambda_signature}" "(")
    ans(ok)
    if(NOT ok)
      return(false)
    endif()
    return(true)
  endfunction()





function(lambda_import lambda_expression function_name)
  lambda_parse("${lambda_expression}")
  ans(lambda_func)
  function_import("${lambda_func}" as ${function_name} REDEFINE)
  return_ans()
endfunction() 







function(lambda_new lambda_expression)
  function_new()
  ans(func)
  lambda_import("${lambda_expression}" "${func}")
  return_ref(func)
endfunction()






#converts a lambda expression into a valid function string
function(lambda result expression)
	string(FIND "${expression}" "function" isfunc)
	
	if("${isfunc}" GREATER "-1")
		set(${result} "${expression}" PARENT_SCOPE)
		return()
	endif()
	string_replace_first("(" "function(lambda_func result "  "${expression}")
  ans(expression)
	string_replace_first(")" ")\n" "${expression}")
  ans(expression)
	set(${result} "${expression}\nendfunction()" PARENT_SCOPE)
endfunction()







function(save_function file_name function_string)
	
	file(WRITE "${file_name}" "${function_string}")
endfunction()





# returns the implementation of the function (a string containing the source code)
# this only works for functions files and function strings. CMake does not offer
# a possibility to get the implementation of a defined function or macro.
function(function_string_get func)
	is_function_string(is_string "${func}")
	if(is_string)
		return_ref(func)
		return()
	endif()

	
	is_function_ref(is_ref "${func}")
	if(is_ref)
		ref_isvalid(${func} )
		ans(is_ref_ref)

		if(is_ref_ref)
			ref_get(${func} )
			ans(res)
			return_ref(res)
			return()
		else()
			set(${func} ${${func}})
		endif()
	endif()


	path("${func}")
	ans(fpath)
	is_function_file(is_file "${fpath}")


	if(is_file)
		load_function(file_content "${fpath}")
		function_string_get( "${file_content}")
		ans(file_content)
		return_ref(file_content)
		return()
	endif()


	is_function_cmake(is_cmake_func "${func}")

	if(is_cmake_func)
		set(source "macro(${func})\n ${func}(\${ARGN})\nendmacro()")
		return_ref(source)		
		return()
	endif()

	lambda_parse("${func}")
	ans(parsed_lambda)

	if(parsed_lambda)
		return_ref(parsed_lambda)
		return()
	endif()

	if(NOT (is_string OR is_file OR is_cmake_func)  )
		message(FATAL_ERROR "the following is not a function: '${func}' ")
	endif()
	return()	

endfunction()




# returns the function content in a list of lines.
# cmake does nto support a list containing a strings which in return contain semicolon
# the workaround is that all semicolons in the source are replaced by a separate line containsing the string ![[[SEMICOLON]]]
# so the number of lines a function has is the number of lines minus the number of lines containsing only ![[[SEMICOLON]]]
function(function_lines_get  func)
	function_string_get( "${func}")
	ans(function_string)
	
	string(REPLACE ";" "![[[SEMICOLON]]]"  function_string "${function_string}")
	string(REPLACE "\n" ";" lines "${function_string}")
	set(res)
	foreach(line ${lines})
		string(FIND "${line}" "![[[SEMICOLON]]]" hasSemicolon)
		if(${hasSemicolon} GREATER "-1")
			string(SUBSTRING "${line}" 0 ${hasSemicolon} part1)
			math(EXPR hasSemicolon "${hasSemicolon} + 16")
			string(SUBSTRING "${line}" ${hasSemicolon} "-1" part2)

			#string(REPLACE "" "${sc}" line "${line}")
			set(res ${res} "${part1}" "![[[SEMICOLON]]]" "${part2}")
		else()
			set(res ${res} ${line})
		endif()
	endforeach()

	return_ref(res)
endfunction()




# creates a and defines a function (with random name)
function(function_new )
	#generate a unique function id

	set(name_base "${__current_constructor}_${__current_member}")
	string_normalize("${name_base}")
	ans(name_base)

	set(id "${name_base}")
	if("${name_base}" STREQUAL "_")
		set(name_base "__func")
		set(id "__func_1111111111")
	endif()

	while(TRUE)
		if(NOT COMMAND "${id}")
			#declare function
			function("${id}")
				message(FATAL_ERROR "function is declared, not defined")
			endfunction()
			return_ref(id)
		endif()
		#message("making_id because ${id} alreading existers")
		make_guid(id)
		set(id "${name_base}_${id}")
	endwhile()


endfunction()




function(function_import callable)
  set(args ${ARGN})
  list_extract_flag(args REDEFINE)
  ans(redefine)
  list_extract_flag(args ONCE)
  ans(once)
  list_extract_labelled_value(args as)
  ans(function_name)

  if(callable STREQUAL "")
    message(FATAL_ERROR "no callable specified")
  endif()

  if(COMMAND "${function_name}" AND function_name AND function_name STREQUAL "${callable}")
    message(DEBUG LEVEL 6 "function '${function_name}' should be imported as '${target_name}' ... returning without operation")
    return()
  endif()

  function_string_get("${callable}")
  ans(function_string)

  if(NOT function_name)
    function_new()
    ans(function_name)
    set(redefine true)
  endif()

  if(COMMAND "${function_name}" AND NOT redefine)
    if(once)
      return()
    endif()
    message(FATAL_ERROR "cannot import '${callable}' as '${function_name}' because it already exists")
  endif()

  function_string_rename("${function_string}" "${function_name}")
  ans(function_string)
  function_string_import("${function_string}")

  return_ref(function_name)
endfunction()




function(is_function_cmake result name)
	if(COMMAND "${name}")
		return_value(true)
	else()
		return_value(false)
	endif()
endfunction()




function(check_function func)
	is_function(res "${func}")
	if(NOT res)
		message(FATAL_ERROR "expected a function instead got: '${func}'")
	endif()
endfunction()




# binds variables to the function
# by caputring their current value and storing
# them
# let funcA : ()->res
# bind(funcA var1 var2)
# will store var1 and var2 and provide them to the funcA call
function(bind func )
  cmake_parse_arguments("" "" "as" "" ${ARGN})
  if(NOT _as)
    function_new()
    ans(_as)
  endif()

  # if func is not a command import it
  if(NOT COMMAND "${func}")
    function_new()
    ans(original_func)
    function_import("${func}" as ${original_func} REDEFINE)
  else()
    set(original_func "${func}")
  endif()

  set(args ${_UNPARSED_ARGUMENTS})

  set(bound_args)
  foreach(arg ${args})
    set(bound_args "${bound_args}\nset(${arg} \"${${arg}}\")")
  endforeach()

  set(evaluate "function(${_as})
${bound_args}
${original_func}(\${ARGN})    
return_ans()
endfunction()")
  set_ans("")
  eval("${evaluate}")
  return_ref(_as)
endfunction()





function(function_parse function_ish)
  is_function(function_type "${function_ish}")
  if(NOT function_type)
    return()
  endif()
  function_string_get( "${function_ish}")
  ans(function_string)
  
  if(NOT function_string)
    return()
  endif()

  function_signature_regex(regex)
  function_signature_get( "${function_string}")
  ans(signature)

  string(REGEX REPLACE ${regex} "\\1" func_type "${signature}" )
  string(REGEX REPLACE ${regex} "\\2" func_name "${signature}" )
  string(REGEX REPLACE ${regex} "\\3" func_args "${signature}" )

  string(STRIP "${func_name}" func_name)

  # get args
  string(FIND "${func_args}" ")" endOfArgsIndex)
  string(SUBSTRING "${func_args}" "0" "${endOfArgsIndex}" func_args)

  if(func_args)
    string(REGEX MATCHALL "[A-Za-z0-9_\\\\-]+" all_args ${func_args})
  endif()

  string(SUBSTRING "${func_args}" 0 ${endOfArgsIndex} func_args)
  string(TOLOWER "${func_type}" func_type)


  map_new()
  ans(res)
  map_set(${res} type "${func_type}")
  map_set(${res} name "${func_name}")
  map_set(${res} args "${all_args}")
  map_set(${res} code "${function_string}")

  return(${res})
endfunction()






## captures variables from the current scope in the function
function(function_capture callable)
  set(args ${ARGN})
  list_extract_labelled_value(args as)
  ans(func_name)
  if(func_name STREQUAL "")
    function_new()
    ans(func_name)
  endif()

  set(captured_var_string)
  foreach(arg ${args})
    set(captured_var_string "${captured_var_string}set(${arg} \"${${arg}}\")\n")
  endforeach()

  function_import("${callable}")
  ans(callable)

  eval("
    function(${func_name})
      ${captured_var_string}
      ${callable}(\${ARGN})
      return_ans()
    endfunction()
  ")
  return_ref(func_name)
endfunction()




function(function_signature_regex result)
	set(${result} "^[ ]*([mM][aA][cC][rR][oO]|[fF][uU][nN][cC][tT][iI][oO][nN])[ ]*\\([ ]*([A-Za-z0-9_\\\\-]*)(.*)\\)" PARENT_SCOPE)
endfunction()




#returns true if the the string val is a function
function(is_function_string result val)
	if(NOT val)
		return_value(false)
	endif()
	#string(MD5 hash "${val}")
	#set(hash "hash_${hash}")
	#get_property(was_checked GLOBAL PROPERTY "${hash}")
	#if(was_checked)
	#return_value(${was_checked})
	#endif()

	string(REGEX MATCH ".*([mM][aA][cC][rR][oO]|[fF][uU][nN][cC][tT][iI][oO][nN])[ ]*\\(" function_found "${val}")
	if(NOT function_found)
		return_value(false)
	endif()
	#set_property(GLOBAL PROPERTY "${hash}" true)
	return_value(true)

endfunction()





  ## universal get function which allows you to get
  ## from an object or map. only allows property names
  ## returns nothing if navigting the object tree fails
  function(get ref_name _equals nav)
    string(REPLACE "." "\;" nav "${nav}")
    set(nav ${nav})
    list_pop_front(nav)
    ans(part)


    set(current "${${part}}")
    map_get_special("${current}" object)
    ans(isobject)

    if(isobject)
      foreach(part ${nav})
        obj_get("${current}" "${part}")
        ans(current)
        if("${current}_" STREQUAL "_")
          break()
        endif()
      endforeach()
    else()
      foreach(part ${nav})
        map_tryget("${current}" "${part}")
        ans(current)
        if("${current}_" STREQUAL "_")
          break()
        endif()
      endforeach()
    endif()
    
    set("${ref_name}" "${current}" PARENT_SCOPE)
  endfunction()





  function(query_fundamental input_callback type)
      
      call("${input_callback}"(${type}))
      ans(res)
      return_ref(res)
  endfunction()




function(proto_declarefunction result)
  string(REGEX MATCH "[a-zA-Z0-9_]+" match "${result}")
  set(function_name "${match}")
  obj_getprototype(${this})
  ans(proto)
	if(NOT proto)
		message(FATAL_ERROR "proto_declarefunction: expected prototype to be present")
	endif()
	set(res ${result})
  set(__current_member ${function_name})
  function_new(${function_name} ${ARGN})
  ans(func)
  obj_set("${proto}" "${function_name}" "${func}")
	#obj_declarefunction(${proto} ${res})
	set(${function_name} "${func}" PARENT_SCOPE)
endfunction()


## shorthand for proto_declarefunction
macro(method result)
  proto_declarefunction("${result}")
endmacro()


# causes the following code inside a constructor to only run once
macro(begin_methods)

endmacro()





function(this_declarefunction result)
	this_check()
	obj_declarefunction(${this} ${result})
	return_value(${${result}})
endfunction()




# appends the value(s) to the specified member variable
function(this_append member_name)
  obj_get("${this}" "${member_name}")
  ans(value)
  obj_set("${this}" "${member_name}" ${value} "${ARGN}")
endfunction()





  function(this_declare_get_keys function_ref)
    obj_declare_get_keys(${this} _ref)
    set(${function_ref} ${_ref} PARENT_SCOPE)
  endfunction()





  function(this_declare_getter function_name_ref)
    obj_declare_getter(${this} _res)
    set(${function_name_ref} ${_res} PARENT_SCOPE)
    return()
  endfunction()




#inherits from base (if base is an objct it will be set as the prototype of this)
# if base is a function / constructor then a base object will be constructed and set
# as the prototy of this
function(this_inherit baseType)
	type_get( ${baseType})
	ans(base)
	obj_getprototype(${this})
	ans(prototype)
	obj_setprototype(${prototype} ${base})
	map_get_special(${base} constructor)
	ans(super)
	function_import("${super}" as base_constructor REDEFINE)
	clr()	
  set(__current_constructor "${super}")
  obj_setprototype(${this} ${base})
	base_constructor(${ARGN})
	obj_setprototype(${this} ${prototype})
	ans(instance)
	if(instance)
		set(this "${instance}" PARENT_SCOPE)
	endif()
endfunction()


## todo
function(obj_inherit)

endfunction()




macro(this_get member_name)
	obj_get("${this}" "${member_name}")
  ans("${member_name}")
endmacro()




# sets both the objects proerpty and the local cmake variable called ${member_name}
function(this_set member_name)
	obj_set("${this}" "${member_name}" "${ARGN}")
	set(${member_name} "${ARGN}" PARENT_SCOPE)
endfunction()








  function(this_declare_setter function_ref)
    obj_declare_setter(${this} _ref)
    set(${function_ref} ${_ref} PARENT_SCOPE)
  endfunction()






function(this_setprototype proto_ref)
	obj_setprototype(${this} ${proto_ref})
endfunction()





function(this_callmember function)
	obj_member_call("${this}" "${function}" ${ARGN})
  return_ans()
endfunction()




function(this_declare_call out_function_name)
  function_new()
  ans(callfunc)
  map_set_special("${this}" call "${callfunc}")
  set(${out_function_name} ${callfunc} PARENT_SCOPE)
endfunction()





# imports all variables specified as varargs
macro(this_import)
  obj_import("${this}" ${ARGN})
endmacro()





  macro(this_capture)
    obj_capture(${this} ${ARGN})
  endmacro()






## shorthand for obj_declare_property 
##
macro(property)
  obj_declare_property(${this} ${ARGN})
endmacro()






  function(this_declare_member_call function_ref)
    obj_declare_member_call(${this} _res)
    set(${function_ref} ${_res} PARENT_SCOPE)
  endfunction()






# returns the objects value at ${key}
function(obj_get this key)
  map_get_special("${this}" "get_${key}")
  ans(getter)
  if(NOT getter)
    map_get_special("${this}" "getter")
    ans(getter)    
    if(NOT getter)
      obj_default_getter("${this}" "${key}")
      return_ans()
    endif()

  endif()
  set_ans("")
  eval("${getter}(\"\${this}\" \"\${key}\")")
  return_ans()
endfunction()








  function(obj_has obj key)
    map_get_special("${obj}" has)
    ans(has)
    if(NOT has)
      obj_default_has_member("${obj}" "${key}")
      return_ans()
    endif()
    set_ans("")
    eval("${has}(\"\${obj}\" \"\${key}\")")
    return_ans()
  endfunction()






  # returns all keys for the specified object
  function(obj_keys obj)
    map_get_special("${obj}" get_keys)
    ans(get_keys)
    if(NOT get_keys)
      obj_default_get_keys("${obj}")
      return_ans()
    endif()
    set_ans("")
    eval("${get_keys}(\"\${obj}\")")
    return_ans()
  endfunction()




# 
function(obj_member_call this key)
  #message("obj_member_call ${this}.${key}(${ARGN})")
  map_get_special("${this}" "member_call")
  ans(member_call)
  if(NOT member_call)
    obj_default_member_call("${this}" "${key}" ${ARGN})
    return_ans()
    #set(member_call obj_default_callmember)
  endif()
  call("${member_call}" ("${this}" "${key}" ${ARGN}))
  return_ans()
endfunction()






  # calls the object itself
  function(obj_call obj)
    map_get_special("${obj}" "call")
    ans(call)

    if(NOT call)
      message(FATAL_ERROR "cannot call '${obj}' - it has no call function defined")
    endif()
    set(this "${obj}")
    call("${call}" (${ARGN}))
    ans(res)
    return_ref(res )
  endfunction()




function(obj_new)
	set(args ${ARGN})
	list_pop_front( args)
	ans(constructor)
	list(LENGTH constructor has_constructor)
	if(NOT has_constructor)
		set(constructor Object)
	endif()
	

	if(NOT COMMAND "${constructor}")
	
		message(FATAL_ERROR "obj_new: invalid type defined: ${constructor}, expected a cmake function")
	endif()

	type_get(${constructor})
	ans(base)
	map_get_special(${base} constructor)
	ans(constr)

	map_new()
	ans(instance)

	obj_setprototype(${instance} ${base})


	set(__current_constructor ${constructor})
	obj_member_call(${instance} __constructor__ ${args})
	ans(res)


	if(res)
		set(instance "${res}")
	endif()

	map_set_special(${instance} "object" true)

	return_ref(instance)
endfunction()





  # sets the objects value at ${key}
  function(obj_set this key)

    map_get_special("${this}" "set_${key}")
    ans(setter)
    if(NOT setter)
      map_get_special("${this}" "setter")
      ans(setter)
      if(NOT setter)
        obj_default_setter("${this}" "${key}" "${ARGN}")
        return_ans()
      endif()
    endif()
    set_ans("")
    eval("${setter}(\"\${this}\" \"\${key}\" \"${ARGN}\")")
    return_ans()
  endfunction()




function(obj_delete this)
 	map_delete(${this})
endfunction()






  # default getter for object properties tries to get
  # the maps own value and if not looks for the prototype
  # special field and calls obj_get on it
  function(obj_default_getter obj key)
    map_has("${obj}" "${key}")
    ans(has_own_property)
    if(has_own_property)
      map_tryget("${obj}" "${key}")
      return_ans()  
    endif()

    map_get_special("${obj}" "prototype")
    ans(prototype)
    #message("proto is ${prototype}")
    if(NOT prototype)
      return()
    endif()

    obj_get("${prototype}" "${key}")
    return_ans()
  endfunction()




# default implementation for returning all avaialbe keys
function(obj_default_get_keys obj)
  map_keys("${obj}")
  ans(ownkeys)
  map_get_special("${obj}" "prototype")
  ans(prototype)
  if(NOT prototype)
    return_ref(ownkeys)
  endif()
  obj_keys("${prototype}")
  ans(parent_keys)
  set(keys ${ownkeys} ${parent_keys})
  list(LENGTH keys len)
  if(${len} GREATER 1)
    list(REMOVE_DUPLICATES keys)
  endif()
  return_ref(keys)
endfunction()





function(obj_injectable_callmember this key)
  map_get_special("${this}" before_call)
  ans(before_call)
  map_get_special("${this}" after_call)
  ans(after_call)

  set(call_this ${this})
  set(call_args ${ARGN})
  set(call_key ${key})
  set(call_result)
  
  if(before_call)
    call("${before_call}"())
  endif()
  obj_default_member_call("${this}" "${key}" "${ARGN}")
  ans(call_result)
  if(after_call)
    call("${after_call}"())
  endif()
  return_ref(call_result)
endfunction()


function(obj_before_callmember obj func)
  map_set_special("${obj}" call_member obj_injectable_callmember)
  map_set_special("${obj}" before_call "${func}")
endfunction()

function(obj_after_callmember obj func)
  map_set_special("${obj}" call_member obj_injectable_callmember)
  map_set_special("${obj}" after_call "${func}")
endfunction()




function(obj_default_has_member obj key)
  map_has("${obj}" "${key}")
  ans(has_member)
  if(has_member)
    return(true)
  endif()
  obj_getprototype("${obj}")
  ans(proto)
  if(NOT proto)
    return(false)
  endif()
  obj_has("${proto}" "${key}")
  return_ans()
endfunction()







  # default setter for object properties sets the
  # owned value @ key
  function(obj_default_setter obj key value)
    map_set("${obj}" "${key}" "${value}")
    return()
  endfunction()





# default implementation for calling a member
# imports all vars int context scope
# and binds this to the calling object
function(obj_default_member_call this key)
  #message("obj_default_callmember ${this}.${key}(${ARGN})")
  obj_get("${this}" "${key}")
  ans(member_function)
  if(NOT member_function)
    message(FATAL_ERROR "member does not exists '${this}.${key}'")
  endif()
  # this elevates all values of obj into the execution scope
  #obj_import("${this}")  
  call("${member_function}"(${ARGN}))
  return_ans()
endfunction()







  function(obj_import obj)
    if(ARGN)
      foreach(arg ${ARGN})
        obj_get("${obj}" "${arg}")
        ans(val)
        set("${arg}" "${val}" PARENT_SCOPE)
      endforeach()
    endif()
    obj_keys("${obj}")
    ans(keys)
    foreach(key ${keys})
      obj_get("${obj}" "${key}")
      ans(val)
      set("${key}" "${val}" PARENT_SCOPE)
    endforeach()

  endfunction()





  function(obj_setprototype obj prototype)
    map_set_special("${obj}" prototype "${prototype}")
    return()
  endfunction()





  ## obj_declare_property_getter(<objref> <propname:string> <getter:cmake function ref>)
  ## declares a property getter for a specific property
  ## after the call getter will contain a function name which needs to be implemented
  ## the getter function signature is (current_object key values...)
  ## the getter function also has access to `this` variable
  function(obj_declare_property_getter obj property_name getter)
    set(args ${ARGN})
    list_extract_flag(args --hidden)
    ans(hidden)
    function_new()
    ans("${getter}")
    if(NOT hidden)
      map_set("${obj}" "${property_name}" "")
    endif()
    map_set_special("${obj}" "get_${property_name}" "${${getter}}")
    set("${getter}" "${${getter}}" PARENT_SCOPE)
  endfunction()





  function(obj_declare_member_call obj function_ref) 
    function_new()
    ans(func)
    map_set_special(${obj} member_call ${func})
    set(${function_ref} ${func} PARENT_SCOPE)
  endfunction()




function(obj_gettype obj)
	obj_getprototype(${obj} )
  ans(proto)
	if(NOT proto)
    return()
	endif()
  map_get_special(${proto} constructor)
  ans(res)
	return_ref(res)
endfunction()


function(typeof obj)
  obj_gettype("${obj}")
  return_ans()
endfunction()




# returns true iff obj is ${typename}
function(obj_istype this typename)
	obj_gethierarchy(${this} )
  ans(hierarchy)
	list(FIND hierarchy ${typename} index)
	if(${index} LESS 0)
		return(false)
	endif()
		return(true)
	endif()
endfunction()






  # creates a new map only getting the specified keys
  function(obj_pick map)
    map_new()
    ans(res)
    foreach(key ${ARGN})
      obj_get(${map} "${key}")
      ans(val)

      map_set("${res}" "${key}" "${val}")
    endforeach()
    return("${res}")
  endfunction()




## declares a programmou able property 
## if one var arg is specified the function is ussed as a getter
## if there are more the one args you need to label the getter with --getter and setter with --setter
## if no var arg is specified the two functions will be created call
## get_${property_name} and set_${property_name}

  function(obj_declare_property obj property_name)
    set(args ${ARGN})
    list_extract_flag(args --hidden)
    ans(hidden)
    if(hidden)
      set(hidden --hidden)
    else()
      set(hidden)
    endif()

    list(LENGTH args len)
    if(${len} EQUAL 0)
      set(getter "get_${property_name}")
      set(setter "set_${property_name}")
    elseif(${len} GREATER 1)
      list_extract_labelled_value(args --getter)
      ans(getter)
      list_extract_labelled_value(args --setter)
      ans(setter)
    else()
      set(getter ${args})
    endif()

    if(getter)
      obj_declare_property_getter("${obj}" "${property_name}" "${getter}" ${hidden})
      set(${getter} ${${getter}} PARENT_SCOPE)
    endif()
    if(setter)
      obj_declare_property_setter("${obj}" "${property_name}" "${setter}" ${hidden})
      set(${setter} ${${setter}} PARENT_SCOPE)
    endif()
  endfunction()





# returns an object from string, or reference
# ie obj("{id:1, test:'asd'}") will return an object
  function(obj object_ish)
    map_isvalid("${object_ish}")
    ans(isobj)
    if(isobj)
      return("${object_ish}")
    endif()
    if("${object_ish}" MATCHES "^{.*}$")
     script("${object_ish}")
     return_ans()
    endif()
    return()
  endfunction()




# shorthand for map_new and obj_new
# accepts a Type (which has to be a cmake function)
function(new)
  obj_new(${ARGN})
  return_ans()
endfunction()


  





  function(obj_getprototype obj)
    map_get_special("${obj}" prototype)
    ans(res)
    return_ref(res)
  endfunction()




# returns a list of prototypes for ${this}
function(obj_gethierarchy this )
	set(current ${this})
	set(types)
	while(current)
		obj_gettype(${current} )
		ans(type)
		if(type)
			list(APPEND types ${type})
		endif()
		obj_getprototype(${current} )
		ans(proto)
		set(current ${proto})
	endwhile()

	return_ref(types)
endfunction()




function(obj_typecheck this typename)
  obj_istype(${this}  ${typename})
  ans(res)
  if(NOT res)
    obj_gettype(${this} )
    ans(actual)
  	message(FATAL_ERROR "type exception expected '${typename} but got '${actual}'")

  endif()
endfunction()





  function(obj_declare_setter obj function_ref)
    function_new()
    ans(res)
    map_set_special(${obj} setter ${res})
    set(${function_ref} ${res} PARENT_SCOPE)
  endfunction()





function(type_exists type)

endfunction()

function(type_get type)
	if(NOT COMMAND ${type})
		message(FATAL_ERROR "obj_new: only cmake functions are allowed as types, '${type}' is not function")
	endif()	
	set(base)
	#get_property(base GLOBAL PROPERTY "type_${type}")
	if(NOT base)
		map_new()
		ans(base)
		
		set_property(GLOBAL PROPERTY "type_${type}" "${base}")
		map_set_special("${base}" constructor "${type}")
	endif()
	return_ref(base)
endfunction()




function(obj_declare_get_keys obj function_ref)
    function_new()
    ans(func)
    map_set_special(${obj} get_keys ${func})
    set(${function_ref} ${func} PARENT_SCOPE)
  endfunction()







  ## tries to parse structured data
  ## if structured data is not parsable returns the value passed
  function(data)
    set(result)
    set(args ${ARGN})
    foreach(arg ${args})
      if("_${arg}" MATCHES "^_(\\[|{).*(\\]|})$")
        script("${arg}")
        ans(val)
      else()
        set(val "${arg}")        
      endif()
      list(APPEND result "${val}")
    endforeach()  
    return_ref(result)
  endfunction()





  function(obj_declare_getter obj function_name_ref)
      function_new()
      ans(func)
      map_set_special(${obj} getter "${func}")
      set(${function_name_ref} ${func} PARENT_SCOPE)
      return()
  endfunction()






function(obj_declare_call obj out_function_name)
  function_new()
  ans(callfunc)
  map_set_special("${obj}" call "${callfunc}")
  set("${out_function_name}" "${callfunc}" PARENT_SCOPE)  
endfunction()  




## sets the a setter functions for a specific property
  function(obj_declare_property_setter obj property_name setter)
    set(args ${ARGN})
    list_extract_flag(args --hidden)
    ans(hidden)
    function_new()
    ans("${setter}")
    if(NOT hidden)
      map_set("${obj}" "${property_name}" "")
    endif()
    map_set_special("${obj}" "set_${property_name}" "${${setter}}")
    set("${setter}" "${${setter}}" PARENT_SCOPE)

  endfunction()







# converts the <structured data?!...> into  <structured data...>
function(objs)
  set(res)
  foreach(arg ${ARGN})
    obj(${arg})
    ans(arg)
    list(APPEND res "${arg}")
  endforeach()
  return_ref(res)
endfunction()




## capture the specified variables in the specified obj
function(obj_capture map)
   set(__obj_capture_args ${ARGN})
    list_extract_flag(__obj_capture_args --notnull)
    ans(__not_null)
    foreach(__obj_capture_arg ${ARGN})
      if("${__obj_capture_arg}" MATCHES "(.+)[:=](.+)")
        set(__obj_capture_arg_key ${CMAKE_MATCH_1})
        set(__obj_capture_arg ${CMAKE_MATCH_2})
      else()
        set(__obj_capture_arg_key "${__obj_capture_arg}")
      endif()
     # print_vars(__obj_capture_arg __obj_capture_arg_key)
      if(NOT __not_null OR NOT "${${__obj_capture_arg}}_" STREQUAL "_")
        obj_set(${map} "${__obj_capture_arg_key}" "${${__obj_capture_arg}}")
      endif()
    endforeach()

endfunction()








  function(ref_keys ref)
    map_get_special("${ref}" object)
    ans(isobject)
    if(isobject)
      obj_keys("${ref}")
    else()
      map_keys("${ref}")
    endif()
    return_ans()
  endfunction()






  function(handler_request)
    set(request "${ARGN}")
    map_isvalid("${request}")
    ans(is_map)

    if(NOT is_map)
      map_new()
      ans(request)
      map_set(${request} input ${ARGN})
    endif()
    return_ref(request)
  endfunction()







  ## creates a default handler from the specified cmake function
  function(handler_default func)
    if(NOT COMMAND "${func}")
      return()
    endif()
      function_new()
      ans(callable)
      function_import("
        function(funcname request response)
          map_tryget(\${request} input)
          ans(input)
          ${func}(\"\${input}\")
          ans(res)
          map_set(\${response} output \"\${res}\")
          return(true)
        endfunction()
        " as ${callable} REDEFINE)

    data("{
      callable:$callable,
      display_name:$func,
      labels:$func
      }")
    ans(handler)

    handler("${handler}")
    return_ans()

  endfunction()







  function(command_line_handler)
    this_set(name "${ARGN}")

    ## forwards the object call operation to the run method
    this_declare_call(call)
    function(${call})

      obj_member_call(${this} run ${ARGN})
      ans(res)
      return_ref(res)
    endfunction()

    method(run)
    function(${run})
      handler_request(${ARGN})
      ans(request)
      assign(handler = this.find_handler(${request}))
      list(LENGTH handler handler_count)  


      if(${handler_count} GREATER 1)
        return_data("{error:'ambiguous_handler',description:'multiple command handlers were found for the request',request:$request}" )
      endif()

      if(NOT handler)
        return_data("{error:'no_handler',description:'command runner could not find an appropriate handler for the specified arguments',request:$request}")
      endif() 
      ## remove first item
      assign(request.input[0] = '') 
      set(parent_handler ${this})
      assign(result = this.execute_handler(${handler} ${request}))
      return_ref(result)

    endfunction()


    method(run_interactive)
    function(${run_interactive})
      if(NOT ARGN)
        echo_append("please enter a command>")
        read_line()
        ans(command)
      else()
        echo("executing command '${ARGN}':")
        set(command "${ARGN}")
      endif()
      obj_member_call(${this} run ${command})
      ans(res)
      table_serialize(${res})
      ans(formatted)
      echo(${formatted})
      return_ref(res)
    endfunction()

    ## compares the request to the handlers
    ## returns the handlers which matches the request
    ## can return multiple handlers
    method(find_handler)
    function(${find_handler})
      handler_request("${ARGN}")
      ans(request)
      this_get(handlers)
      handler_find(handlers "${request}")
      ans(handler)
      return_ref(handler)
    endfunction()

    ## executes the specified handler 
    ## the handler must not be part of this command runner
    ## it takes a handler and a request and returns a response object
    method(execute_handler)
    function(${execute_handler} handler)
      handler_request(${ARGN})
      ans(request)
      map_set(${request} runner ${command_line_handler})
      map_new()
      ans(response)
      handler_execute("${handler}" ${request} ${response})
      return_ref(response)
    endfunction()

    ## adds a request handler to this command handler
    ## request handler can be any function/function definition 
    ## or handler object
    method(add_handler)
    function(${add_handler})
      handler(${ARGN})
      ans(handler)
      if(NOT handler)
        return()
      endif()
      map_append(${this} handlers ${handler})
      
      return(${handler})
    endfunction()

  ## property contains a managed list of handlers
  property(handlers)
  ## setter
  function(${set_handlers} obj key new_handlers)
    map_tryget(${this} handlers)
    ans(old_handlers)
    if(old_handlers)
      list(REMOVE_ITEM new_handlers ${old_handlers})
    endif()

    set(result)
    foreach(handler ${new_handlers})
      set_ans("")
      obj_member_call(${this} add_handler ${handler})
      ans(res)
      list(APPEND result ${res})
    endforeach()
    return_ref(result)
  endfunction()
  ## getter
  function(${get_handlers})
    map_tryget(${this} handlers)
    return_ans()
  endfunction()


endfunction()







  ## executes a handler
  function(handler_execute handler request)
    handler(${handler})
    ans(handler)
    data(${request})
    ans(request)
    data(${ARGN})
    ans(response)
    if(NOT response)
      data("{output:''}")
      ans(reponse)
    endif()
    assign(!response.request = request)
    if(NOT handler)
      assign(!response.error = 'handler_invalid')
      assign(!response.message = "'handler was not valid'")
    else()
      assign(!response.handler = handler)
      map_tryget(${handler} callable)
      ans(callable)
      call(${callable}("${request}" "${response}"))
      ans(result)
    endif()
    return_ref(response)
  endfunction()




# returns those handlers in handler_lst which match the specified request  
  function(handler_find handler_lst request)
    set(result)
    foreach(handler ${${handler_lst}})
      handler_match(${handler} ${request})
      ans(res)
      if(res)
        list(APPEND result ${handler})
      endif()
    endforeach()

    return_ref(result)
  endfunction() 





## creates a handler 
## 
function(handler handler)
  data("${handler}")
  ans(handler)
  map_isvalid(${handler})
  ans(is_map)
  
  if(is_map)  
    map_tryget(${handler} callable)
    ans(callable)
    if(NOT COMMAND "${callable}")
      function_new()
      ans(new_callable)
      function_import("${callable}" as "${new_callable}" REDEFINE)
      map_set(${handler} callable "${new_callable}")
    endif()
    return(${handler})
  endif()

  if(COMMAND "${handler}")
    set(callable ${handler})
    if(NOT ARGN)
      handler_default("${callable}")
      return_ans()
    endif()
  else()
    function_new()
    ans(callable)
    function_import(${handler} as ${callable} REDEFINE)
    set(callable ${callable})
  endif()
  map_capture_new(
    callable
  )
  return_ans()
endfunction()




## checks of the handler can handle the specified request
## this is done by look at the first input argument and checking if
## it is contained in labels
function(handler_match handler request)
    map_tryget(${handler} labels)
    ans(labels)

    map_tryget(${request} input)
    ans(input)

    list_pop_front(input)
    ans(cmd)

    list_contains(labels "${cmd}")
    ans(is_match)

    return_ref(is_match)
endfunction()





function(memory_cache_clear cache_key)
  memory_cache_key("${cache_key}")
  ans(key)
  map_set_hidden(memory_cache_entries "${key}")
  return()
endfunction()






function(file_cache_update cache_key)
  file_cache_key("${cache_key}")
  ans(path)
  qm_serialize("${ARGN}")
  ans(ser)
  file(WRITE "${path}" "${ser}")
  return()  
endfunction()






macro(memory_cache_return_hit cache_key)
  memory_cache_get("${cache_key}")
  ans(__cache_return)
  if(__cache_return)
    return_ref(__cache_return)
  endif()
endmacro()




function(memory_cache_exists cache_key)
  memory_cache_key("${cache_key}")
  ans(key)
  map_tryget(memory_cache_entries "${key}")
  ans(entry)
  if(entry)
    return(true)
  endif()
  return(false)
endfunction()





  function(memory_cache_key cache_key)
    ref_isvalid("${cache_key}")
    ans(isref)
    if(isref)
      json("${cache_key}")
      ans(cache_key)
    endif()
 #  message("ck ${cache_key}")
    return_ref(cache_key)
  endfunction()






  function(cached retrieve refresh compute_key)
    set(args ${ARGN})
    list_extract_flag(args --refresh)
    ans(refresh_cache)

    if(compute_key STREQUAL "")
      string_combine("_" ${args})
      ans(cache_key)
      string(MD5 "${cache_key}" cache_key)
    else()
      call("${compute_key}"(${args}))
      ans(cache_key)
    endif()
    
    oocmake_config(temp_dir)
    ans(temp_dir)

    set(cache_dir "${temp_dir}/dir_cache/${cache_key}")
    if(EXISTS "${cache_dir}" NOT refresh_cache)
      call("${retrieve}"(args))
      return_ans()
    endif()

    pushd("${cache_dir}" --create)
    call("${refresh}"(args))
    ans(result)
    popd()

    if(NOT result)
      rm("${cache_dir}")
      return()
    endif()

    call("${retrieve}"(args))
    ans(result)

    return_ref(result)
  endfunction()






  function(cache_clear cache_key)
    memory_cache_clear("${cache_key}")
    file_cache_clear("${cache_key}")

  endfunction()






function(file_cache_get cache_key)
  file_cache_key("${cache_key}")
  ans(path)
  if(EXISTS "${path}")
    qm_deserialize_file("${path}")
    return_ans()
  endif()
  return()
endfunction()






macro(file_cache_return_hit cache_key)
  file_cache_get("${cache_key}")
  ans(__cache_return)
  if(__cache_return)
    return_ref(__cache_return)
  endif()

endmacro()






  function(memory_cache_get cache_key)
    set(args ${ARGN})
    list_extract_flag(args --const)
    ans(isConst)

    memory_cache_key("${cache_key}")
    ans(key)
    map_tryget(memory_cache_entries "${key}")
    ans(value)
    if(NOT isConst)
      map_clone_deep("${value}")
      ans(value)
    endif()
#    
    return_ref(value)
  endfunction()


  






function(file_cache_exists cache_key)
  file_cache_key("${cache_key}")
  ans(path)
  if(EXISTS "${path}")
    return(true)
  endif()
  return(false)
endfunction()





  function(cache_get cache_key)
    memory_cache_get("${cache_key}")
    ans(res)
    if(res)
      return_ref(res)
    endif()
    file_cache_get("${cache_key}")
    ans(res)
    if(res)
      memory_cache_update("${cache_key}" "${res}")
      return_ref(res)
    endif()
  endfunction()





  function(cache_update cache_key value)
    memory_cache_update("${cache_key}" "${value}" ${ARGN})
    file_cache_update("${cache_key}" "${value}" ${ARGN})
  endfunction()





function(file_cache_clear_all)
  oocmake_config(temp_dir)
  ans(temp_dir)
  file(REMOVE_RECURSE "${temp_dir}/file_cache")
endfunction()






  function(cache_exists cache_key)
    memory_cache_exists("${cache_key}")
    ans(res)
    if(res)
      return_ref(res)
    endif()
    file_cache_exists("${cache_key}")
    ans(res)
    return_ref(res)
  endfunction()







  function(memory_cache_update cache_key value)
    set(args ${ARGN})
    list_extract_flag(args --const)
    ans(isConst)
    if(NOT isConst)
        map_clone_deep("${value}")
        ans(value)
    endif()

    memory_cache_key("${cache_key}")
    ans(key)
    
    map_set_hidden(memory_cache_entries "${key}" "${value}")
  endfunction()






function(file_cache_clear cache_key)
  file_cache_key("${cache_key}")
  ans(path)
  if(EXISTS "${path}")
    file(REMOVE "${path}")
  endif()
  return()
endfunction()





function(file_cache_key cache_key)
  ref_isvalid("${cache_key}")
  ans(isref)
  if(isref)
    json("${cache_key}")
    ans(cache_key)
  endif()
  checksum_string("${cache_key}")
  ans(key)
  oocmake_config(temp_dir)
  ans(temp_dir)
  set(file "${temp_dir}/file_cache/_${key}.cmake")
  return_ref(file)
endfunction()





macro(cache_return_hit cache_key)
  cache_get("${cache_key}")
  ans(__cache_return)
  if(__cache_return)
    return_ref(__cache_return)
  endif()
endmacro()








function(file_data_set dir id nav)
  set(args ${ARGN})

  if("${nav}" STREQUAL "." OR "${nav}_" STREQUAL "_")
    file_data_write("${dir}" "${id}" ${ARGN})
    return_ans()
  endif()
  file_data_read("${dir}" "${id}")
  ans(res)
  map_navigate_set("res.${nav}" ${ARGN})
  file_data_write("${dir}" "${id}" ${res})
  return_ans()
endfunction()


   
  






  function(fallback_data_set dirs id nav)
    list_pop_front(dirs)
    ans(dir)

    file_data_set("${dir}" "${id}" "${nav}" ${ARGN})
    return_ans()
  endfunction()





  ## same as file_data_write except that an <obj> is parsed 
  function(file_data_write_obj dir id obj)
    obj("${obj}")
    ans(obj)
    file_data_write("${dir}" "${id}" "${obj}")
    return_ans()
  endfunction()





## returns the user data path for the specified id
## id can be any string that is also usable as a valid filename
## it is located in %HOME_DIR%/.oocmake
function(user_data_path id)  
  if(NOT id)
    message(FATAL_ERROR "no id specified")
  endif()
  user_data_dir()
  ans(storage_dir)
  set(storage_file "${storage_dir}/${id}.cmake")
  return_ref(storage_file)
endfunction()






## sets and persists data for the current user specified by identified by <id> 
## nav can be empty or a "." which will set the data at the root level
## else it can be a navigation expressions which (see map_navigate_set)
## e.g. user_data_set(common_directories oocmake.base_dir /home/user/mydir)
## results in common_directories to contain
## {
##   oocmake:{
##     base_dir:"/home/user/mydir"
##   }
## }
function(user_data_set id nav)
  set(args ${ARGN})

  if("${nav}" STREQUAL "." OR "${nav}_" STREQUAL "_")
    user_data_write("${id}" ${ARGN})
    return_ans()
  endif()
  user_data_read("${id}")
  ans(res)
  map_navigate_set("res.${nav}" ${ARGN})
  user_data_write("${id}" ${res})
  return_ans()
endfunction()






### returns the user data stored under the index id
## user data may be any kind of data  
function(user_data_read id)
  user_data_path("${id}")
  ans(storage_file)

  if(NOT EXISTS "${storage_file}")
    return()
  endif()

  qm_read("${storage_file}")
  return_ans()
endfunction()




## writes all var args into user data, accepts any typ of data 
## maps are serialized
function(user_data_write id)
  user_data_path("${id}")
  ans(path)
  qm_write("${path}" ${ARGN})
  return_ans()
endfunction()






  function(fallback_data_get dirs id)
    set(res)
    foreach(dir ${dirs})
      file_data_get("${dir}" "${id}" ${ARGN})
      ans(res)
      if(res)
        break()
      endif()
    endforeach()
    return_ref(res)
  endfunction()







function(file_data_path dir id)
  path("${dir}/${id}.cmake")
  ans(path)
  return_ref(path)    
endfunction()





  ## same as user_data_write except that an <obj> is parsed 
  function(user_data_write_obj id obj)
    obj("${obj}")
    ans(obj)
    user_data_write("${id}" "${obj}")
    return_ans()
  endfunction()










  function(fallback_data_read dirs id)    
    set(maps )
    foreach(dir ${dirs})
      file_data_read("${dir}" "${id}")
      ans(res)
      list(APPEND maps "${res}")
    endforeach()
    list(REVERSE maps)
    map_merge(${maps})
    ans(res)
    return_ref(res)
  endfunction()






## returns data (read from storage) for the current user which is identified by <id>
## if no navigation arg is specified then the root data is returned
## else a navigation expression can be specified which returns a specific VALUE
## see nav function
function(user_data_get id)
  set(nav ${ARGN})
  user_data_read("${id}")
  ans(res)
  if("${nav}_" STREQUAL "_" OR "${nav}_" STREQUAL "._")
    return_ref(res)
  endif()
  nav(data = "res.${nav}")
  return_ref(data)
endfunction()




## returns the source dir for the specified navigation argument
function(fallback_data_source dirs id)
  set(res)
  foreach(dir ${dirs})
    file_data_get("${dir}" "${id}" ${ARGN})
    ans(res)
    if(res)
      return_ref(dir)
    endif()
  endforeach()
  return()
endfunction()




## signature user_data_clear(<id:identifier>^"--all")
### removes the user data associated to identifier id
## WARNING: if --all flag is specified instead of an id all user data is deleted
## 
function(user_data_clear)
  set(args ${ARGN})
  list_extract_flag(args --all)
  ans(all)
  set(id ${args})
  if(all)
    user_data_ids()
    ans(ids)
    foreach(id ${ids})
      user_data_clear("${id}")
    endforeach()
  endif()
  user_data_path("${id}")
  ans(res)
  if(EXISTS "${res}")
    rm("${res}")
    return(true)
  endif()
  return(false)
endfunction()





## returns the <qualified directory> where the user data is stored
# this is the home dir/.oocmake
function(user_data_dir)    
  home_dir()
  ans(home_dir)
  set(storage_dir "${home_dir}/.oocmake")
  if(NOT EXISTS "${storage_dir}")
    mkdir("${storage_dir}")
  endif()
  return_ref(storage_dir)
endfunction()




## returns all identifiers for user data
function(user_data_ids)
  user_data_dir()
  ans(dir)
  file_glob("${dir}" *.cmake)
  ans(files)
  set(keys)
  foreach(file ${files})
    path_component("${file}" --file-name)
    ans(key)
    list(APPEND keys "${key}")
  endforeach()
  return_ref(keys)
endfunction()






function(file_data_read dir id)
  file_data_path("${dir}" "${id}")      
  ans(path)
  if(NOT EXISTS "${path}")
    return()
  endif()
  qm_read("${path}")
  return_ans()
endfunction()







function(file_data_get dir id)
  set(nav ${ARGN})
  file_data_read("${dir}" "${id}")
  ans(res)
  if("${nav}_" STREQUAL "_" OR "${nav}_" STREQUAL "._")
    return_ref(res)
  endif()
  nav(data = "res.${nav}")
  return_ref(data)
endfunction()






function(file_data_clear dir id)
  file_data_path("${dir}" "${id}")
  ans(path)
  if(NOT EXISTS "${path}")
    return(false)
  endif()
  rm("${path}")
  return(true)
endfunction()







function(file_data_write dir id)
  file_data_path("${dir}" "${id}")
  ans(path)
  qm_write("${path}" ${ARGN})
  return_ref(path)
endfunction()





## returns all identifiers for specified file data directory
function(file_data_ids dir)
  path("${dir}")
  ans(dir)
  file_glob("${dir}" *.cmake)

  ans(files)
  set(keys)
  foreach(file ${files})
    path_component("${file}" --file-name)
    ans(key)
    list(APPEND keys "${key}")
  endforeach()
  return_ref(keys)
endfunction()





  function(ast_parse_regex definition stream create_node)
    nav(regex = "definition.regex")
    # regex - try match
    if(NOT regex)
      return(false)
    endif()
   # message("regex: ${regex}")
    stream_take_regex(${stream} "${regex}")
    ans(match)
  #  message("matched: '${match}'")
    if(NOT match)
      return(false)
    endif()
    nav(replace = definition.replace)
    if(replace)
      #message("replace: ${replace}")
      string(REGEX REPLACE "${regex}" "\\${replace}" match "${match}")
    endif()
    if(NOT create_node)
     # message("create_node: ${create_node}")
      return(true)
    endif()
    map_new()
    ans(node)
    map_set(${node} data "${match}")
    return(${node})
  endfunction()




function(language name)
  map_new()
  ans(language_map)
  ref_set(language_map "${language_map}")


function(language name)
  ## get cached language
  ref_get(language_map)
  ans(language_map)

  map_isvalid("${name}")
  ans(ismp)
  if(ismp)
    map_tryget(${name}  initialized)
    ans(initialized)
    if(NOT initialized)
      language_initialize(${name})
    endif()
    map_tryget(${name} name)
    ans(lang_name)
    map_tryget(${language_map} ${lang_name})
    ans(existing_lang)
    if(NOT existing_lang)
      map_set(${language_map} ${lang_name} ${name})
    endif()
    return_ref(name)
  endif()

  map_tryget(${language_map}  "${name}")
  ans(language)


  if(NOT language)
    language_load(${name})
    ans(language)

    if(NOT language)
      return()
    endif()
    map_set(${language_map} "${name}" ${language})
    
    map_get(${language}  name)
    ans(name)
    map_set(${language_map} "${name}" ${language})
    set_ans("")
    eval("function(eval_${name} str)
    language(\"${name}\")
    ans(lang)
    ast(\"\${str}\" \"${name}\" \"\")
    ans(ast)
    map_new()
    ans(context)
      #message(\"evaling '\${ast}' with lang '\${lang}' context is \${context} \")
    ast_eval(\${ast} \${context} \${lang})
    ans(res)
    return_ref(res)
    endfunction()")
  endif()
  return_ref(language)
endfunction()

language("${name}" ${ARGN})
return_ans()

endfunction()




# executes the language file, input can be given by a key value list
  function(lang2 target language)
    map_from_keyvaluelist("" ${ARGN})
    ans(ctx)
    language("${language}")
    ans(language)
    
    obj_setprototype("${ctx}" "${language}")
    lang("${target}" "${ctx}")
    ans(res)

    
    return_ref(res)
  endfunction()




function(language_load definition_file)
  if(NOT EXISTS "${definition_file}")
    return()
  endif()
  json_read("${definition_file}")
  ans(language)
  string(MD5 hash "${data}")
  map_set(${language} md5 "${hash}")
 # ref_print(${language})
  if(NOT language)
    return()
  endif()
  language_initialize(${language})

  return_ref(language)
endfunction()






  function(ast_parse_token )#definition stream create_node definition_id
    #message(FORMAT "trying to parse {definition.name}")
   # ref_print("${definition}")
   # ref_print(${definition})

    token_stream_take(${stream} ${definition})
    ans(token)

    if(NOT token)
      return(false)
    endif()
    
    #message(FORMAT "parsed {definition.name}: {token.data}")
    if(NOT create_node)
      return(true)
    endif()

    map_tryget(${definition}  replace)
    ans(replace)
    if(replace)
      map_get(${token}  data)
      ans(data)
      map_get(${definition}  regex)
      ans(regex)
      string(REGEX REPLACE "${regex}" "\\${replace}" data "${data}")
      #message("data after replace ${data}")
      map_set_hidden(${token} data "${data}")
    endif()
    
    map_set_hidden(${token} types ${definition_id})
    return(${token})

  endfunction()





  function(token_stream_push stream)
    map_get(${stream}  stack)
    ans(stack)
    map_tryget(${stream}  current)
    ans(current)
    stack_push(${stack} ${current})

   # message("pushed")
  endfunction()




function(ast_parse stream definition_id )

  #message_indent_push()
  if(ARGN)
      set(args ${ARGN})
      list_pop_front( args)
      ans(ast_language)

      map_get(${ast_language}  parsers)
      ans(ast_parsers)
      map_get(${ast_language}  definitions)
      ans(ast_definitions)
      function_import_table(${ast_parsers} __ast_call_parser)

#      json_print(${ast_definitions})
  else()
      if(NOT ast_language)
          message(FATAL_ERROR "missing ast_language")
      endif()
  endif()

 # map_get(${ast_language} parsers parsers)
  map_get("${ast_definitions}"  "${definition_id}")
  ans(definition)
 
  map_tryget(${definition}  node)
  ans(create_node)
  map_get(${definition}  parser)  
  ans(parser)
  map_get(${ast_parsers}  "${parser}")
  ans(parser_command)
  map_tryget(${definition}  peek)
  ans(peek)

  #message("trying to parse ${definition_id} with ${parser} parser")
  if(peek)
    token_stream_push(${stream})
  endif()  
  #eval("${parser_command}(\"${definition}\" \"${stream}\" \"${create_node}\")")

  __ast_call_parser("${parser}" "${definition}" "${stream}" "${create_node}")
  ans(node)
  if(peek)
    token_stream_pop(${stream})
  endif()
 
 #if(node)
 #  message(FORMAT "parsed {node.types}")
 #else()
 #  message("failed to parse ${definition_id}")
 #endif()
 #  message_indent_pop()
  return_ref(node)
endfunction()





  function(token_stream_take stream token_definition)
   # message(FORMAT "trying to take {token_def_or_name.name}")
    map_tryget(${stream}  current)
    ans(current)
    if(NOT current)
      return()
    endif()
#    message(FORMAT "current token '{current.data}'  is a {current.definition.name}, expected {definition.name}")
    
    map_tryget(${current}  definition)
    ans(definition)
    
    if(${definition} STREQUAL ${token_definition})
   
      map_tryget(${current}  next)
      ans(next)
      map_set_hidden(${stream} current ${next})
      return(${current})
    endif()
    return()
  endfunction()




function(expr_compile_identifier)# ast context
  
#message("ast: ${ast}")
  
  map_tryget(${ast}  data)
  ans(data)
  set(res "
  # expr_compile_identifier
  #map_tryget(\"\${local}\" \"${data}\")
  scope_resolve(\"${data}\")
  obj_get(\"\${this}\" \"${data}\")
  # end of expr_compile_identifier")
  return_ref(res)
endfunction()




function(expr_compile_expression_statement) # context, ast
  map_tryget(${ast}  children)
  ans(statement_ast)
  ast_eval(${statement_ast} ${context})
  ans(statement)
  set(res "
  # expr_compile_statement
  ${statement}
  # end of expr_compile_statement")
  return_ref(res)  
endfunction()




function(expr_compile_new)
#json_print(${ast})
  map_tryget(${ast} children)
  ans(children)

  list_extract(children className_ast call_ast)

  map_tryget(${className_ast} data)
  ans(className)

  map_tryget(${call_ast} children)
  ans(argument_asts)


 # message("class name is ${className} ")

  set(arguments)
  set(evaluation)
  set(i 0)

  make_symbol()
  ans(symbol)

  foreach(argument_ast ${argument_asts})
    ast_eval(${argument_ast} ${context})
    ans(argument)

    set(evaluation "${evaluation}
  ${argument}
  ans(${symbol}_arg${i})")
    set(arguments "${arguments}\"\${${symbol}_arg${i}}\" " )
    math(EXPR i "${i} + 1")
  endforeach()

  set(res "
#expr_compile_new
${evaluation}
obj_new(\"${className}\" ${arguments})
#end of expr_compile_new
  ")


return_ref(res)
endfunction()




function(expr_eval_identifier)# ast scope
  message("identifier")
  ref_print(${ast})
endfunction()




function(expr_compile_list)
  map_tryget(${ast}  children) 
  ans(element_asts)
  set(arguments)
  set(evaluation)
  set(i 0)

  make_symbol()
  ans(symbol)
  set(elements)
  foreach(element_ast ${element_asts})
    ast_eval(${element_ast} ${context})
    ans(element)

    set(evaluation "${evaluation}
  ${element}
  ans(${symbol}_arg${i})")
    set(elements "${elements}\"\${${symbol}_arg${i}}\" " )
    math(EXPR i "${i} + 1")
  endforeach()
  set(res "
  #expr_compile_list
  ${evaluation}
  set(${symbol} ${elements})
  set_ans_ref(${symbol})
  #end of expr_compile_list")
  return_ref(res)
endfunction()




function(expr_compile_cmake_identifier)
  #message("cmake_identifier")
  #ref_print(${ast})
  map_get(${ast}  children)
  ans(identifier)
  map_get(${identifier}  data)
  ans(identifier)
  
  set(res "
  #expr_compile_cmake_identifier
  if(COMMAND \"${identifier}\")
    set_ans(\"${identifier}\")
  else() 
    set_ans_ref(\"${identifier}\") 
  endif()
  # end of expr_compile_cmake_identifier")
  return_ref(res)
endfunction()




function(expr_eval_expression)
#  message("evaluating expression")
  map_get(${ast}  children)
  ans(children)
    map_new()
    ans(new_context)
  map_set(${new_context} parent_context ${context})
  map_tryget(${context}  scope)
  ans(scope)
  map_set(${new_context} scope ${scope})

  foreach(rvalue_ast ${children})
    ast_eval(${rvalue_ast} ${new_context})
    ans(rvalue)
    map_set(${new_context} left ${rvalue})
    map_set(${new_context} left_ast ${rvalue_ast})
  endforeach()


  map_tryget(${new_context}  left)
  ans(left)
  return_ref(left)
endfunction()




function(expr_compile_call)
  map_tryget(${ast}  children) 
  ans(argument_asts)
  set(arguments)
  set(evaluation)
  set(i 0)


  make_symbol()
  ans(symbol)

  foreach(argument_ast ${argument_asts})
    ast_eval(${argument_ast} ${context})
    ans(argument)

    set(evaluation "${evaluation}
  ${argument}
  ans(${symbol}_arg${i})")
    set(arguments "${arguments}\"\${${symbol}_arg${i}}\" " )
    math(EXPR i "${i} + 1")
  endforeach()

  set(res "
  # expr_compile_call 
  ${evaluation}
  call(\"\${left}\"(${arguments}))
  # end of expr_compile_call")

  return_ref(res)
endfunction()




function(expr_compile_assignment) # scope, ast

  #message("compiling assignment")
  map_tryget(${ast}  children)
  ans(children)
  list_extract(children lvalue_ast rvalue_ast)

  map_tryget(${lvalue_ast}  types)
  ans(types)
  list_extract(types lvalue_type) 
  set(res)


  if("${lvalue_type}" STREQUAL "cmake_identifier" )
    #message("assigning cmake identifier")
    map_tryget(${lvalue_ast}  children)
    ans(children)
    list_extract(children identifier_ast)
    map_tryget(${identifier_ast}  data)
    ans(identifier)
    set(res "
  set(assignment_key \"${identifier}\")
  set(assignment_scope \"\${global}\")")
  elseif("${lvalue_type}" STREQUAL "identifier")
   # message("assigning identifier")
    map_tryget(${lvalue_ast}  data)
    ans(identifier)
    set(res "
  set(assignment_key \"${identifier}\")
  set(assignment_scope \"\${this}\")")
  elseif("${lvalue_type}" STREQUAL "indexation")
    map_tryget(${lvalue_ast}  children)
    ans(indexation_ast)
    ast_eval(${indexation_ast} ${context})
    ans(indexation)
    set(res "
  ${indexation}
  ans(assignment_key)
  set(assignment_scope \"\${this}\")")
  endif()

  ast_eval(${rvalue_ast} ${context})
  ans(rvalue)
  set(res "
  # expr_compile_assignment
  ${rvalue}
  ans(rvalue)
  ${res}
  map_set(\"\${assignment_scope}\" \"\${assignment_key}\" \"\${rvalue}\" )
  set_ans_ref(rvalue)
  # end of expr_compile_assignment")
  return_ref(res)   
endfunction()




function(expr_compile_function) # context, ast
 # message("expr_compile_function")

  map_tryget(${ast} children)
  ans(children)

  #message("children ${children}")

  list_extract(children signature_ast body_ast)

  map_tryget(${signature_ast} children)
  ans(signature_identifiers)
  set(signature_vars)
  set(identifiers)
  foreach(identifier ${signature_identifiers})
    map_tryget(${identifier} data)
    ans(identifier)
    list(APPEND identifiers "${identifier}")
    set(signature_vars "${signature_vars} ${identifier}")
  endforeach()  
  #message("signature_identifiers ${identifiers}")

  map_tryget(${body_ast} types)
  ans(body_types)

  list_contains(body_types closure)
  ans(is_closure)
  
  if(is_closure)
   map_tryget(${body_ast} children)
    ans(body_ast)

  endif()

  make_symbol()
  ans(symbol)
 # message("body_types ${body_types}")

  ast_eval(${body_ast} ${context})
  ans(body)

map_append_string(${context} code "#expr_compile_function
function(\"${symbol}\"${signature_vars})
  map_new()
  ans(local)  
  map_capture(\"\${local}\" this global${signature_vars})
  ${body}
  return_ans()
endfunction()
#end of expr_compile_function")
  

  set(res "set_ans(\"${symbol}\")")

  return_ref(res)  
endfunction()




## file containing data from resources/expr.json 
function(expr_definition)
map()
 key("name")
  val("oocmake")
 key("phases")
 map()
  key("name")
   val("tokenize")
  key("function")
   val("token_stream_new\(/1\ /2\)")
  key("input")
   val("global")
   val("str")
  key("output")
   val("tokens")
 end()
 map()
  key("name")
   val("parse")
  key("function")
   val("ast_parse\(/1\ /2\ /3\ /4\ /5\)")
  key("input")
   val("tokens")
   val("root_definition")
   val("global")
   val("parsers")
   val("definitions")
  key("output")
   val("ast")
 end()
 map()
  key("name")
   val("compile")
  key("function")
   val("ast_eval\(/1\ /2\ /3\ /4\)")
  key("input")
   val("ast")
   val("context")
   val("global")
   val("evaluators")
  key("output")
   val("symbol")
 end()
 key("parsers")
 map()
  key("token")
   val("ast_parse_token")
  key("any")
   val("ast_parse_any")
  key("sequence")
   val("ast_parse_sequence")
  key("list")
   val("ast_parse_list")
  key("empty")
   val("ast_parse_empty")
  key("end_of_stream")
   val("ast_parse_end_of_stream")
 end()
 key("evaluators")
 map()
  key("string")
   val("expr_compile_string")
  key("number")
   val("expr_compile_number")
  key("cmake_identifier")
   val("expr_compile_cmake_identifier")
  key("call")
   val("expr_compile_call")
  key("expression")
   val("expr_compile_expression")
  key("bind")
   val("expr_compile_bind")
  key("indexation")
   val("expr_compile_indexation")
  key("identifier")
   val("expr_compile_identifier")
  key("list")
   val("expr_compile_list")
  key("new_object")
   val("expr_compile_new_object")
  key("assignment")
   val("expr_compile_assignment")
  key("parentheses")
   val("expr_compile_parentheses")
  key("null_coalescing")
   val("expr_compile_coalescing")
  key("statements")
   val("expr_compile_statements")
  key("expression_statement")
   val("expr_compile_expression_statement")
  key("function")
   val("expr_compile_function")
  key("if")
   val("expr_compile_if")
  key("while")
   val("expr_compile_while")
  key("for")
   val("expr_compile_for")
  key("foreach")
   val("expr_compile_foreach")
  key("new")
   val("expr_compile_new")
 end()
 key("root_definition")
  val("statements")
 key("definitions")
 map()
  key("statements")
  map()
   key("node")
    val("true")
   key("parser")
    val("list")
   key("element")
    val("statement")
  end()
  key("if")
  map()
   key("node")
    val("true")
   key("parser")
    val("any")
   key("any")
    val("if_else")
    val("if_only")
  end()
  key("for_keyword")
  map()
   key("parser")
    val("token")
   key("regex")
    val("for")
  end()
  key("while_keyword")
  map()
   key("parser")
    val("token")
   key("regex")
    val("while")
  end()
  key("new")
  map()
   key("parser")
    val("sequence")
   key("node")
    val("true")
   key("sequence")
    val("new_keyword")
    val("identifier")
    val("call")
  end()
  key("for")
  map()
   key("node")
    val("true")
   key("parser")
    val("sequence")
   key("sequence")
    val("for_keyword")
    val("paren_open")
    val("expression")
    val("expression")
    val("expression")
    val("paren_close")
    val("statement")
  end()
  key("while")
  map()
   key("node")
    val("true")
   key("parser")
    val("sequence")
   key("sequence")
    val("while_keyword")
    val("paren_open")
    val("expression")
    val("paren_close")
    val("statement")
  end()
  key("foreach")
  map()
   key("node")
    val("true")
   key("parser")
    val("sequence")
   key("sequence")
    val("while_keyword")
    val("paren_open")
    val("expression")
    val("paren_close")
    val("statement")
  end()
  key("if_only")
  map()
   key("node")
    val("true")
   key("parser")
    val("sequence")
   key("sequence")
    val("if_keyword")
    val("paren_open")
    val("expression")
    val("paren_close")
    val("statement")
  end()
  key("if_else")
  map()
   key("node")
    val("true")
   key("parser")
    val("sequence")
   key("sequence")
    val("if_only")
    val("else_keyword")
    val("statement")
  end()
  key("if_keyword")
  map()
   key("parser")
    val("token")
   key("regex")
    val("if")
  end()
  key("else_keyword")
  map()
   key("parser")
    val("token")
   key("regex")
    val("else")
  end()
  key("expression_statement")
  map()
   key("parser")
    val("sequence")
   key("node")
    val("true")
   key("sequence")
    val("expression")
    val("end_of_statement")
  end()
  key("statement")
  map()
   key("parser")
    val("any")
   key("any")
    val("expression_statement")
  end()
  key("end_of_statement")
  map()
   key("parser")
    val("any")
   key("any")
    val("semicolon")
    val("end_of_stream")
  end()
  key("expression")
  map()
   key("node")
    val("true")
   key("parser")
    val("list")
   key("begin")
    val("value")
   key("element")
    val("operation")
   key("end")
    val("end_of_expression")
  end()
  key("function")
  map()
   key("node")
    val("true")
   key("parser")
    val("sequence")
   key("sequence")
    val("function_signature")
    val("hyphen")
    val("angular_bracket_close")
    val("function_body")
  end()
  key("hyphen")
  map()
   key("parser")
    val("token")
   key("regex")
    val("[-]")
  end()
  key("angular_bracket_open")
  map()
   key("parser")
    val("token")
   key("regex")
    val("[<]")
  end()
  key("angular_bracket_close")
  map()
   key("parser")
    val("token")
   key("regex")
    val("[>]")
  end()
  key("function_signature")
  map()
   key("node")
    val("true")
   key("parser")
    val("list")
   key("element")
    val("identifier")
   key("begin")
    val("paren_open")
   key("end")
    val("paren_close")
   key("separator")
    val("comma")
  end()
  key("function_body")
  map()
   key("parser")
    val("any")
   key("any")
    val("closure")
    val("expression")
  end()
  key("closure")
  map()
   key("parser")
    val("sequence")
   key("node")
    val("true")
   key("sequence")
    val("brace_open")
    val("statements")
    val("brace_close")
  end()
  key("value")
  map()
   key("parser")
    val("any")
   key("any")
    val("assignment")
    val("function")
    val("parentheses")
    val("literal")
    val("lvalue")
    val("list")
    val("new_object")
    val("new")
  end()
  key("lvalue")
  map()
   key("parser")
    val("any")
   key("any")
    val("cmake_identifier")
    val("identifier")
    val("indexation")
  end()
  key("operation")
  map()
   key("parser")
    val("any")
   key("any")
    val("assignment")
    val("identifier")
    val("call")
    val("bind")
    val("indexation")
    val("null_coalescing")
  end()
  key("null_coalescing")
  map()
   key("node")
    val("true")
   key("parser")
    val("sequence")
   key("sequence")
    val("query")
    val("query")
    val("expression")
  end()
  key("query")
  map()
   key("parser")
    val("token")
   key("regex")
    val("[?]")
  end()
  key("parentheses")
  map()
   key("node")
    val("true")
   key("parser")
    val("sequence")
   key("sequence")
    val("paren_open")
    val("expression")
    val("paren_close")
  end()
  key("assignment")
  map()
   key("node")
    val("true")
   key("parser")
    val("sequence")
   key("sequence")
    val("lvalue")
    val("equals")
    val("expression")
  end()
  key("indexation")
  map()
   key("node")
    val("true")
   key("parser")
    val("sequence")
   key("sequence")
    val("bracket_open")
    val("expression")
    val("bracket_close")
  end()
  key("bind")
  map()
   key("node")
    val("true")
   key("parser")
    val("sequence")
   key("sequence")
    val("period")
  end()
  key("new_object")
  map()
   key("node")
    val("true")
   key("parser")
    val("sequence")
   key("sequence")
    val("key_value_list")
  end()
  key("key_value_list")
  map()
   key("parser")
    val("list")
   key("node")
    val("true")
   key("begin")
    val("brace_open")
   key("end")
    val("brace_close")
   key("element")
    val("key_value")
   key("separator")
    val("comma")
  end()
  key("call")
  map()
   key("parser")
    val("list")
   key("begin")
    val("paren_open")
   key("element")
    val("expression")
   key("separator")
    val("comma")
   key("end")
    val("paren_close")
   key("node")
    val("true")
  end()
  key("end_of_expression")
  map()
   key("parser")
    val("any")
   key("peek")
    val("true")
   key("any")
    val("comma")
    val("paren_close")
    val("semicolon")
    val("bracket_close")
    val("brace_close")
    val("end_of_stream")
  end()
  key("list")
  map()
   key("parser")
    val("list")
   key("begin")
    val("bracket_open")
   key("end")
    val("bracket_close")
   key("separator")
    val("comma")
   key("element")
    val("expression")
   key("node")
    val("true")
  end()
  key("new_keyword")
  map()
   key("parser")
    val("token")
   key("regex")
    val("new")
  end()
  key("key_value")
  map()
   key("parser")
    val("sequence")
   key("node")
    val("true")
   key("sequence")
    val("key")
    val("colon")
    val("key_value_value")
  end()
  key("key_value_value")
  map()
   key("parser")
    val("any")
   key("any")
    val("list")
    val("expression")
  end()
  key("key")
  map()
   key("parser")
    val("any")
   key("any")
    val("identifier")
    val("string")
  end()
  key("identifier")
  map()
   key("parser")
    val("token")
   key("node")
    val("true")
   key("regex")
    val("\([a-zA-Z_-][a-zA-Z0-9_\\-]*\)")
   key("except")
    val("\(new|for|while\)")
  end()
  key("cmake_identifier")
  map()
   key("parser")
    val("sequence")
   key("node")
    val("true")
   key("sequence")
    val("dollar")
    val("identifier")
  end()
  key("end_of_stream")
  map()
   key("parser")
    val("end_of_stream")
  end()
  key("nothing")
  map()
   key("parser")
    val("empty")
   key("empty")
    val("true")
  end()
  key("colon")
  map()
   key("parser")
    val("token")
   key("regex")
    val("[:]")
  end()
  key("semicolon")
  map()
   key("parser")
    val("token")
   key("regex")
    val("[\\\\\;]")
  end()
  key("period")
  map()
   key("parser")
    val("token")
   key("regex")
    val("[\\.]")
  end()
  key("dollar")
  map()
   key("parser")
    val("token")
   key("regex")
    val("[\\\$]")
  end()
  key("equals")
  map()
   key("parser")
    val("token")
   key("regex")
    val("=")
  end()
  key("literal")
  map()
   key("parser")
    val("any")
   key("any")
    val("string")
    val("number")
  end()
  key("paren_close")
  map()
   key("parser")
    val("token")
   key("regex")
    val("[\)]")
  end()
  key("paren_open")
  map()
   key("parser")
    val("token")
   key("regex")
    val("[\(]")
  end()
  key("bracket_close")
  map()
   key("parser")
    val("token")
   key("regex")
    val("]")
  end()
  key("bracket_open")
  map()
   key("parser")
    val("token")
   key("regex")
    val("[\\[]")
  end()
  key("brace_close")
  map()
   key("parser")
    val("token")
   key("regex")
    val("[}]")
  end()
  key("brace_open")
  map()
   key("parser")
    val("token")
   key("regex")
    val("[{]")
  end()
  key("comma")
  map()
   key("parser")
    val("token")
   key("match")
    val(",")
  end()
  key("string")
  map()
   key("parser")
    val("token")
   key("node")
    val("true")
   key("regex")
    val("'\(\([\^']|\\\\'\)*\)'")
   key("replace")
    val("1")
  end()
  key("number")
  map()
   key("parser")
    val("token")
   key("node")
    val("true")
   key("regex")
    val("\([1-9][0-9]*\)")
  end()
  key("white_space")
  map()
   key("parser")
    val("token")
   key("ignore_token")
    val("true")
   key("regex")
    val("[\r\n\t\ ]+")
  end()
 end()
end()
ans(res)
return_ref(res)

endfunction()




function(expr_compile_coalescing)
  map_tryget(${ast}  children)
  ans(expr_ast)
  ast_eval(${expr_ast} ${context})
  ans(expr)
  set(res "
  # expr_compile_coalescing 
  if(NOT left)
    ${expr}
  endif()
  # end of expr_compile_coalescing")
  return_ref(res)
endfunction()




function(expr_compile_string) # scope, ast

  map_tryget(${ast}  data)
  ans(data)
  make_symbol()
  ans(symbol)
  
 
  set(res "
  # expr_compile_string
  set_ans(\"${data}\")
  # end of expr_compile_string")
  return_ref(res)  
endfunction()




function(expr_eval_string) # scope, ast
  map_tryget(${ast}  data)
  ans(data)
  return_ref(data)  
endfunction()




function(expr_compile_parentheses)

  map_tryget(${ast}  children)
  ans(expression_ast)
  ast_eval(${expression_ast} ${context})
  ans(expression)

  set(res "
  # expr_compile_parentheses
  ${expression}
  # end of expr_compile_parentheses")


  return_ref(res)
endfunction()




function(expr_eval_call)
  map_tryget(${ast}  children) 
  ans(argument_asts)
  set(arguments)
  foreach(argument_ast ${argument_asts})
    ast_eval(${argument_ast} ${context})
    ans(argument)
    set(arguments "${arguments}\"${argument}\" " )
  endforeach()
  map_get(${context}  left)
  ans(invokation_target)
  set(invokation "${invokation_target}"("${arguments}"))
  call("${invokation}")
  return_ans()
endfunction()




function(expr_compile_bind)
  set(res "
  # expr_compile_bind 
  set(this \"\${left}\")
  # end of expr_compile_bind")
  return_ref(res)
endfunction()




function(expr_compile_number) # scope, ast

  map_tryget(${ast}  data)
  ans(data)
  make_symbol()
  ans(symbol)
  
 
  set(res "
  # expr_compile_number
  set_ans(\"${data}\")
  # end of expr_compile_number")
  return_ref(res)  
endfunction()




function(expr_eval_cmake_identifier)
  #message("cmake_identifier")
  #ref_print(${ast})
  map_get(${ast}  children)
  ans(identifier)
  map_get(${identifier}  data)
  ans(identifier)

  if(NOT "${identifier}" AND COMMAND "${identifier}")
    
  else()
    set(identifier "${${identifier}}")
  endif()
#  message("returning ${identifier}")
  return_ref(identifier)
endfunction()




function(expr_compile_indexation)
  map_tryget(${ast}  children)
  ans(indexation_expression_ast)
  ast_eval(${indexation_expression_ast} ${context})
  ans(indexation_expression)

  set(res "
  # expr_compile_indexation
  ${indexation_expression}
  ans(index)
  set(this \"\${left}\")
  map_get(\"\${this}\" \"\${index}\")
  # end of expr_compile_indexation")


  return_ref(res)
endfunction()




function(expr_compile_statements) # scope, ast
  map_tryget(${ast}  children)
  ans(statement_asts)
  set(statements)
  #message("children: ${statement_asts}")
  list(LENGTH statement_asts len)
  set(index 0)
  foreach(statement_ast ${statement_asts})
    math(EXPR index "${index} + 1")
    ast_eval(${statement_ast} ${context})
    ans(statement)
    set(statements "${statements}
  #statement ${index} / ${len}
  ${statement}")
  endforeach()
  map_tryget(${ast}  data)
  ans(data)
  make_symbol()
  ans(symbol)
  
  make_symbol()
  ans(symbol)

  map_append_string(${context} code "
# expr_compile_statements
function(\"${symbol}\")
  ${statements}
  return_ans()
endfunction()
# end of expr_compile_statements")
  
  set(res "${symbol}()")

#  message("${res}")
  return_ref(res)  
endfunction()




function(expr_compile_new_object)
  map_tryget(${ast}  children)
  ans(keyvalues)
  map_tryget(${keyvalues}  children)
  ans(keyvalues)

  make_symbol()
  ans(symbol)

  set(evaluation)
  foreach(keyvalue ${keyvalues})
    map_tryget(${keyvalue}  children)
    ans(pair)
    list_extract(pair key_ast value_ast)
    map_tryget(${key_ast}  data)
    ans(key)
    ast_eval(${value_ast} ${context})
    ans(value)
    #string(REPLACE "\${" "\${" value "${value}")
    set(evaluation "${evaluation}
    ${value}
    ans(${symbol}_tmp)
    map_set(\"\${${symbol}}\" \"${key}\" \"\${${symbol}_tmp}\")")
  endforeach()

  set(res "
  #expr_compile_new_object
  map_new()
  ans(${symbol})
  ${evaluation}
  set_ans_ref(${symbol})
  #end of expr_compile_new_object
  ")

  return_ref(res)

endfunction()




function(expr_compile_expression)
  #message("compiling expression")
  map_get(${ast}  children)
  ans(children)
  set(result "")
  
  list(LENGTH children len)
  if(len GREATER 1)

    make_symbol()
    ans(symbol)
    foreach(rvalue_ast ${children})
      ast_eval(${rvalue_ast} ${context})
      ans(rvalue)

      set(result "${result}
  ${rvalue}
  ans(left)")
      map_set(${context} left ${rvalue})
      map_set(${context} left_ast ${rvalue_ast})
    endforeach()
    
    map_append_string(${context} code "
#expr_compile_expression
function(${symbol})
  set(left)
  ${result}
  return_ref(left)
endfunction()
#end of expr_compile_expression")

    set(symbol "
  #expr_compile_expression
  ${symbol}()
  #end of expr_compile_expression")
  else()
    ast_eval(${children} ${context})
    ans(symbol)
  endif()


  return_ref(symbol)
endfunction()




# parses an abstract syntax tree from str
function(ast str language)
  language("${language}")
  ans(language)
  # set default root definition to expr
  set(root_definition ${ARGN})
  if(NOT root_definition)
    
    map_get("${language}"  root_definition)
    ans(root_definition)
  endif()



  # transform str to a stream
  token_stream_new(${language} "${str}")
  ans(stream)
  # parse ast and return result
  ast_parse(${stream} "${root_definition}" ${language})
  return_ans()
endfunction()





function(language_initialize language)
  # sets up the language object
    
  map_tryget(${language}  initialized)
  ans(initialized)
  if(initialized)
    return(${language})
  endif()


  # setup token definitions

  # setup definition names
  map_get(${language}  definitions)
  ans(definitions)
  map_keys(${definitions})
  ans(keys)
  foreach(key ${keys})
    map_get(${definitions}  ${key})
    ans(definition)
    map_set(${definition} name ${key} )
  endforeach()  

  #
  token_definitions(${language})
  ans(token_definitions)
  map_set(${language} token_definitions ${token_definitions})

  map_set(${language} initialized true)


  # extract phases
  map_tryget(${language} phases)
  ans(phases)
#  ref_isvalid("${phases}")
#  ans(isref)
#  if(isref)
#    ref_get(${phases})
#    ans(phases)
#  endif()
  map_set(${language} phases "${phases}")


  # setup self reference
  map_set(${language} global ${language})
  

  # setup outputs
  foreach(phase ${phases})
    map_tryget(${phase} name)
    ans(name)
    map_set("${language}" "${name}" "${phase}")

    map_tryget("${phase}" output)
    ans(outputs)
    if(outputs)
 #     ref_isvalid("${outputs}")
 #     ans(isref)
#      if(isref)
 #       ref_get(${outputs})
  #      ans(outputs)
   #   endif()
      map_set("${phase}" output "${outputs}")

      foreach(output ${outputs})
        map_set(${language} "${output}" "${phase}")
      endforeach()
    endif()
  endforeach()



  # setup inputs
  foreach(phase ${phases})
    map_tryget("${phase}" input)
    ans(inputs)
    if(inputs)
#      ref_isvalid("${inputs}")
 #     ans(isref)
  #    if(isref)
   #     ref_get(${inputs})
    #    ans(inputs)
    # endif()
      map_set("${phase}" input "${inputs}")
     # message("inputs for phase ${phase} ${inputs}")

      foreach(input ${inputs})
        map_tryget(${language} "${input}")
        ans(val)
        if(NOT val)
          map_set(${language} "${input}" "missing")
        
         # message("missing input: ${input}")
        endif()

      endforeach()
    endif()
  endforeach()


endfunction()





  function(ast_json_eval_boolean )#ast scope
    map_get(${ast}  data)
    ans(data)
    return_ref(data)
  endfunction()





  function(ast_json_eval_null )#ast scope
    map_get(${ast}  data)
    ans(data)
    return()
  endfunction()





  function(ast_json_eval_object )#ast scope
    map_new()
    ans(map)
    map_get(${ast}  children)
    ans(keyvalues)
    foreach(keyvalue ${keyvalues})
      ast_eval(${keyvalue} ${map})
    endforeach()
    return(${map})
  endfunction()





  function(ast_json_eval_string )#ast scope
    map_get(${ast}  data)
    ans(data)
    return_ref(data)
  endfunction()





  function(ast_json_eval_key_value )#ast scope
    map_get(${ast}  children)
    ans(value)
    list_pop_front( value)
    ans(key)
    ast_eval(${key} ${context})
    ans(key)
    ast_eval(${value} ${context})
    ans(value)

    #message("keyvalue ${key}:${value}")
    map_set(${context} ${key} ${value})
  endfunction()





  function(ast_json_eval_number )#ast scope
    map_get(${ast}  data)
    ans(data)
    return_ref(data)
  endfunction()





  function(ast_json_eval_array )#ast scope
    map_get(${ast}  children)
    ans(values)
    set(res)
    foreach(value ${values})
      ast_eval(${value} ${context})
      ans(evaluated_value)
      list(APPEND res "${evaluated_value}")
    endforeach()
    return_ref(res)
  endfunction()




function(ast_eval_identifier ast scope)
  map_get(${ast}  data)
  ans(identifier)
  message("resolving identifier: ${identifier} in '${scope}'")

  map_has(${scope}  "${identifier}")
  ans(has_value)
  if(has_value)
    map_get(${scope}  "${identifier}")
    ans()
    return_ref(value)
  endif()
  #message("no value in scope")

  if(COMMAND "${identifier}")
   # message("is command")
    return_ref(identifier)
  endif()

  if(DEFINED "${identifier}")
    message("is a cmake var")
    return_ref(${identifier})
  endif()
  return()  
  endfunction()




function(ast_parse_any )#definition stream create_node definition_id
  # check if definition contains "any" property
  map_tryget(${definition}  any)
  ans(any)
#  ref_get(${any})
#  ans(any)
  
  # try to parse any of the definitions contained in "any" property
  set(node false)
  foreach(def ${any})    
    ast_parse(${stream} "${def}")
    ans(node)
    if(node)
      break()
    endif()
  endforeach()

  # append definition to current node if a node was returned
  ref_isvalid("${node}")
  ans(is_map)
  if(is_map)
  
    map_append(${node} types ${definition_id})
  endif()
  
  
  
  return_ref(node)
endfunction()






  function(ast_parse_match definition stream create_node)
    # check if definition can be parsed by ast_parse_match
    map_tryget("${definition}"  match)
    ans(match)
    if(NOT match)
      return(false)
    endif()

    # take string specified in match from stream (if stream does)
    # not start with "${match}" nothing is returned
   # message("matching match ${match}")
#    stream_print(${stream})
    stream_take_string(${stream} "${match}")
    ans(res)
    # could not parse if stream did not match "${match}"
    if("${res}_" STREQUAL "_")
      return(false)
    endif()

    # return result
    if(NOT create_node)
      return(true)
    endif()
    map_new(node)
    ans(node)
    map_set(${node} data ${data})
    return(${node})
 endfunction()





  function(ast_eval ast context)
    if(ARGN)
      set(args ${ARGN})
      list_pop_front( args)
      ans(ast_language)
      map_tryget(${ast_language}  evaluators)
      ans(ast_evaluators)
      function_import_table(${ast_evaluators} ast_evaluator_table)

    endif()
    if(NOT ast_evaluators)
      message(FATAL_ERROR "no ast_evaluators given")
    endif()
  
    #message("evaluator prefix ${ast_evaluators}... ${ARGN}")
    map_get(${ast}  types)
    ans(types)
    map_isvalid("${ast_evaluators}" )
    ans(ismap)
    while(true)
      list_pop_front( types)    
      ans(type) 
      map_tryget(${ast_evaluators}  "${type}")
      ans(eval_command)
     # message("eval command ist ${eval_command}")
      # avaible vars
      # ast context ast_language ast_evaluators
      # available commands ast_evaluator_table
      if(COMMAND "${eval_command}")
        ast_evaluator_table(${type})
        ans(res)
        return_ref(res)
      endif()
      #if(COMMAND "${eval_command}")
       # eval("${eval_command}(\"${ast}\" \"${scope}\")")
        #ans(res)
        #return_ans()
      #endif()
    endwhile()
  endfunction()





function(make_symbol)
  ref_get(symbol_count)
  ans(i)
  if(NOT i)
    function(make_symbol)
      ref_get(symbol_count )
      ans(i)
      math(EXPR i "${i} + 1")
      ref_set(symbol_count "${i}")
      return("symbol_${i}_${symbol_cache_key}")
    endfunction()
    ref_set(symbol_count 1)
    return(symbol_1)
  endif()
  message(FATAL_ERROR "make_symbol")
 endfunction()




# parses str into a linked list of tokens 
# using token_definitions
function(tokens_parse token_definitions str)
  map_new()
  ans(first_token)
  set(last_token ${first_token})
  while(true) 
    # recursion anker
    string_isempty( "${str}")
    ans(isempty)
    if(isempty)
      map_tryget(${first_token}  next)
      ans(first_token)
      return(${first_token})
    endif()

    set(token)
    set(ok)
    foreach(token_definition ${token_definitions})
      map_tryget(${token_definition}  regex)
      ans(regex)
    #  message("trying ${regex} with '${str}'")
      #set(match)
      string(REGEX MATCH "^(${regex})" match "${str}")
      list(LENGTH match len)
      if("${len}" GREATER 0)
        map_tryget(${token_definition} except)
        ans(except)
        list(LENGTH except hasExcept)
        if(NOT hasExcept OR NOT "_${match}" MATCHES "_(${except})")

          #message(FORMAT "matched {token_definition.name}  match: '${match}' ")
          #message("stream ${str}")     
          string(LENGTH "${match}" len)
          string(SUBSTRING "${str}" "${len}" -1 str)
          token_new(${token_definition} "${match}")
          ans(token)
     #     message(FORMAT "token {token_definition.regex} matches ${match}")
          set(ok true)
          break()
        endif()
      endif()
    endforeach()

    if(NOT ok)
#      message("failed - not a token  @ ...${str}")
      return()
    endif()

    if(token)
      if(last_token)
        map_set(${last_token} next ${token})
      endif()
      set(last_token ${token})
    endif()
  endwhile()

endfunction()






 function(ast_parse_list )#definition stream create_node
 
   # message("parsing list")
    token_stream_push(${stream})

    map_tryget(${definition}  begin)
    ans(begin)
    map_tryget(${definition}  end)
    ans(end)
    map_tryget(${definition}  separator)
    ans(separator)
    map_get(${definition}  element)
    ans(element)
   # message(" ${begin} <${element}> <${separator}> ${end}")
    
    #message("create node ${create_node}")
    if(begin)
      ast_parse(${stream} ${begin})
      ans(begin_ast)
      
      if(NOT begin_ast)
        token_stream_pop(${stream})
        return(false)
      endif()

    endif()
    set(child_list)
    while(true)
      if(end)
        ast_parse(${stream} ${end})
        ans(end_ast)
        if(end_ast)
          break()
        endif()
      endif()

      if(separator)
        if(child_list)
          ast_parse(${stream} ${separator})
          ans(separator_ast)

          if(NOT separator_ast)
            token_stream_pop(${stream})
          #  message("failed")
            return(false)
          endif()
        endif()
      endif()
      
      ast_parse(${stream} ${element})
      ans(element_ast)

      if(NOT element_ast)
        #failed because no element was found
        if(NOT end)
          break()
        endif()
        return(false)
      endif()
      list(APPEND child_list ${element_ast})

     # message("appending child ${element_ast}")

      

    endwhile()
    #message("done ${create_node}")
    token_stream_commit(${stream})

    if(NOT create_node)
      return(true)
    endif()
#    message("creating node")

    map_isvalid("${begin_ast}" )
    ans(isnode)
    if(NOT isnode)
      set(begin_ast)
    endif()
    map_isvalid("${end_ast}" )
    ans(isnode)
    if(NOT isnode)
      set(end_ast)
    endif()
    map_tryget(${definition}  name)
    ans(def)
    map_new()
    ans(node)
    map_set(${node} types ${def})
    map_set(${node} children ${begin_ast} ${child_list} ${end_ast})
    return(${node})
  endfunction()





  function(token_stream_commit stream)
    map_get(${stream}  stack)
    ans(stack)
    stack_pop(${stack})
  endfunction()





  function(token_stream_new language str)
    map_get(${language}  token_definitions)
    ans(token_definitions)
   # messagE("new token strean ${token_definitions}")

    #ref_print(${language})

    tokens_parse("${token_definitions}" "${str}")
    ans(tokens)
    map_new()
    ans(stream)
    map_set(${stream} current ${tokens})
    stack_new()
    ans(stack)
    map_set(${stream} stack ${stack})
    map_set(${stream} first ${tokens})
    return_ref(stream)
  endfunction()





function(script str)


  map_new()
  ans(expression_cache)
  map_set(global expression_cache ${expression_cache})
  function(script str)
    language("oocmake")
    ans(lang)
    if(NOT lang)
      #oocmake_config(base_dir)
      #ans(base_dir)

      #language("${base_dir}/resources/expr.json")
      expr_definition()
      ans(lang)
      language("${lang}")
      ans(lang)

    endif()
    map_tryget("${lang}" md5)
    ans(language_hash)
    string(MD5 script_language_hash "${str}${language_hash}")  
    oocmake_config(temp_dir)
    ans(temp_dir)
    set(obj_file "${temp_dir}/expressions/expr_${script_language_hash}.cmake")
    map_tryget(global expression_cache)
    ans(expression_cache)

    map_tryget(${expression_cache} "${script_language_hash}")
    ans(symbol)
    if(symbol)

    elseif(EXISTS "${obj_file}")
      include("${obj_file}")
      ans(symbol)
      map_set(${expression_cache} "${script_language_hash}" "${symbol}")
    else()
#      echo_append("compiling expression to ${obj_file} ...")
      map_new()
      ans(context)

      map_new(scope)
      ans(scope)

      map_set(${context} scope "${scope}")
      map_set(${context} cache_key "${script_language_hash}")
      set(symbol_cache_key "${script_language_hash}")
      ast("${str}" oocmake "")
      ans(ast)

      ast_eval(${ast} ${context} ${lang})
      ans(symbol)
      string(REPLACE "\"" "\\\"" escaped "${symbol}")
      string(REPLACE "$" "\\$" escaped "${escaped}")
      map_tryget(${context} code)
      ans(code)
 #     message("done")
      file(WRITE "${obj_file}" "${code}\nset(__ans \"${escaped}\")")
      if(code)
        set_ans("")
        eval("${code}")
      endif()

    endif()

  map_isvalid("${global}" )
    ans(ismap)
    if(NOT ismap)
      map_new()
      ans(global)
    endif()
    set_ans("")
    eval("${symbol}")
    ans(res)

    if(NOT ismap)

      map_promote(${global})
    endif()
    return_ref(res)
  endfunction()
  script("${str}")
  return_ans()
endfunction()





  function(ast_eval_assignment ast scope)
    message("eval assignment")
    map_get(${ast} children)
    #ans(children)

    #ref_get(${children})
    ans(rvalue)
    list_pop_front( rvalue)
    ans(lvalue)
    ref_print("${lvalue}")
    ref_print("${rvalue}")
    ast_eval(${rvalue} ${scope})
    ans(val)
    message("assigning value ${val} to")

    map_get(${lvalue} types)
    ans(types)
    message("types for lvalue ${types}")

    map_get(${lvalue} identifier)
    ans(identifier)
    map_set(${scope} "${identifier}" ${val})

  endfunction()




function(expr_import str function_name)
  expr_compile("${str}")
  ans(symbol)
  set_ans("")
  eval("
function(${function_name})
  map_isvalid(\"${global}\" )
  ans(ismap)
  if(NOT ismap)
    map_new()
    ans(global)
  endif()
  ${symbol}
  ans(res)
  if(NOT ismap)
    map_promote(${global})
  endif()
  return_ref(res)
endfunction()")
  return_ans()
endfunction()





  function(ast_parse_empty )#definition stream create_node
    map_tryget(${definition}  empty)
    ans(is_empty)
    if(NOT is_empty)
      return(false)
    endif()
   # message("parsed empty!")
    if(NOT create_node)
      return(true)
    endif()

    map_new()
    ans(node)
    return(${node})
  endfunction()





  function(token_stream_pop stream)
    map_get(${stream}  stack)
    ans(stack)
    stack_pop(${stack})
    ans(current)
    map_set(${stream} current ${current})
  #  message(FORMAT "popped to {current.data}")
  endfunction()





  function(token_stream_move_next stream)
    map_get(${stream}  current)
    ans(current)
    map_tryget(${current}  next)
    ans(next)
    map_set(${stream} current ${next})
   # message(FORMAT "moved from {current.data} to {next.data}")
  endfunction()







  function(ast_eval_literal ast scope)
    map_get(${ast} literal data)
    ans(literal)
    return_ref(literal)
  endfunction()





function(ast_parse_end_of_stream)
  token_stream_isempty(${stream})
  return_ans()
endfunction()




function(expr_compile str)
  map_new()
  ans(expression_cache)
  ref_set(__expression_cache ${expression_cache})
  function(expr_compile str)
    set(ast)
    ref_get(__expression_cache )
    ans(expression_cache)
    map_tryget(${expression_cache}  "${str}")
    ans(symbol)
    if(NOT symbol)
      # get ast
      language("oocmake")
      ans(language)
      if(NOT language)
        oocmake_config(base_dir)
        ans(base_dir)
        language("${base_dir}/resources/expr.json")
        ans(language)
      endif()
      #message("compiling ast for \"${str}\"")
      ast("${str}" oocmake "")
      ans(ast)
      #message("ast created")
      # compile to cmake
      map_new()
      ans(context)
      map_new()
      ans(scope)
      map_set(${context} scope ${scope})    
      ast_eval(${ast} ${context} ${language})
      ans(symbol)
      map_tryget(${context}  code)
      ans(code)
      if(code)
       # message("${code}")
        set_ans("")
        eval("${code}")
      endif()
      map_set(${expression_cache} "${str}" ${symbol})
    endif()
    #eval("${symbol}")
    #return_ans()
    return_ref(symbol)
  endfunction()
  expr_compile("${str}")
  return_ans()
endfunction()





  function(token_stream_isempty stream)
    map_tryget(${stream}  current)
    ans(current)
    if(current)
      return(false)
    endif()
    return(true)

  endfunction()




function(ast_parse_sequence )#definition stream create_node definition_id
  map_tryget("${definition}"  sequence)
  ans(sequence)
  set(rsequence)
  if(NOT sequence)
    map_tryget("${definition}"  rsequence)
    ans(sequence)
    set(rsequence true)
  endif()
  if(NOT sequence)
    message(FATAL_ERROR "expected a sequence or a rsequence")
  endif()
  # deref ref array
#  ref_get(${sequence} )
#  ans(sequence)
  
  # save current stream
  #message("push")
  token_stream_push(${stream})

  # empty var for sequence
  set(ast_sequence)

  # loop through all definitions in sequence
  # adding all resulting nodes in order to ast_sequence
  foreach(def ${sequence})
    ast_parse(${stream} "${def}")
    ans(res)
    if(res) 
      map_isvalid(${res} )
      ans(ismap)
      if(ismap)
        list(APPEND ast_sequence ${res})
      endif()
    else()
     # message("pop")
      token_stream_pop(${stream})
      return(false)
    endif()
   
  endforeach()
  token_stream_commit(${stream})
  # return result
  if(NOT create_node)
    return(true)
  endif()
  map_new()
  ans(node)
  map_set(${node} types ${definition_id})
  
  map_set(${node} children ${ast_sequence})
  return(${node})
endfunction()





# returns the token definitions of a language 
function(token_definitions language)
  map_get(${language}  definitions)
  ans(definitions)
  map_keys(${definitions} )
  ans(keys)
  set(token_definitions)
  foreach(key ${keys})
    map_get(${definitions}  ${key})
    ans(definition)
    map_tryget(${definition}  parser)
    ans(parser)
    if("${parser}" STREQUAL "token")
      map_set(${definition} name "${key}")
      map_tryget(${definition}  regex)
      ans(regex)
      if(regex)
        map_set(${token_definition} regex "${regex}")
      else()
        map_tryget(${definition}  match)
        ans(match)
        string_regex_escape("${match}")
        ans(match)
        map_set(${definition} regex "${match}")
      endif()
      list(APPEND token_definitions ${definition})
    endif()
  endforeach()
  return_ref(token_definitions)
endfunction()




  function(token_new definition data)
    map_tryget(${definition}  ignore_token)
    ans(ignore_token)
    if(ignore_token)
      return()
    endif()
    map_new()
    ans(token)
    map_set(${token} definition ${definition})
    map_set(${token} data "${data}")
    return_ref(token)
  endfunction()





  function(lang target context)    
    #message("target ${target}")
    obj_get(${context} phases)
    ans(phases)

   

    # get target value from
    obj_has(${context} "${target}")
    ans(has_target)
    if(NOT has_target)
      message(FATAL_ERROR "missing target '${target}'")        
    endif()
    obj_get(${context} "${target}")
    ans(current_target)

    if("${current_target}_" STREQUAL "_")
        return()
    endif()

    # check if phase
    list_contains(phases "${current_target}")
    ans(isphase)    
    # if not a phase just return value
    if(NOT isphase)
      return_ref("current_target")
    endif()


    # target is phase 
    map_tryget("${current_target}" name)
    ans(name)


    # get inputs for current target
    obj_get("${current_target}" "input")
    ans(required_inputs)

    # setup required imports
    map_new()
    ans(inputs)
    foreach(input ${required_inputs})
        #message_indent_push()
        #message("getting ${input} ${required_inputs}")

        lang("${input}" ${context})
        ans(res)
        #message("got ${res} for ${input}")
        #message_indent_pop()
        map_set(${inputs} "${input}" "${res}")
    endforeach()

    # handle function call
    map_tryget("${current_target}" function)
    ans(func)

    # curry function to specified arguments
    curry2("${func}")
    ans(func)

    # compile argument string

    map_keys(${inputs})
    ans(keys)
    set(arguments_string)
    foreach(key ${keys})
      map_tryget(${inputs} "${key}")
      ans(val)
      cmake_string_escape("${val}")
      ans(val)
      #message("key ${key} val ${val}")
      #string(REPLACE "\\" "\\\\"  val "${val}")
      #string(REPLACE "\"" "\\\"" val "${val}")
      set(arguments_string "${arguments_string} \"${val}\"")
    endforeach()
    # call curried function - note that context is available to be modified
    set(func_call "${func}(${arguments_string})")
 
   # message("lang: target '${target}'  func call ${func_call}")
   set_ans("")
    eval("${func_call}")
    ans(res)    
   # message("res '${res}'")
    obj_set(${context} "${target}" "${res}")

    # set single output to return value
    map_tryget(${current_target} output)
    ans(outputs)
    list(LENGTH outputs len)
    if(${len} EQUAL 1)
      set(${context} "${outputs}" "${res}")
    endif()

    map_tryget(${context} "${target}")
    ans(res)

    return_ref(res)
  endfunction()





  function(evaluate str language expr)
    language(${language})
    ans(language)

    set(scope ${ARGN})
    map_isvalid("${scope}" )
    ans(ismap)
    if(NOT ismap)
      map_new()
      ans(scope)
      foreach(arg ${ARGN})
        map_set(${scope} "${arg}" ${${arg}})
      endforeach()
    endif()


    map_new()
    ans(context)
    map_set(${context} scope ${scope})

  #  message("expr ${expr}")

    ast("${str}" ${language} "${expr}")
    #return("gna")
    ans(ast) 
   # ref_print(${ast})
    ast_eval(${ast} ${context} ${language})
    ans(res)
    if(NOT ismap)
      map_promote(${scope})
    endif()
    return_ref(res)
  endfunction()







  function(ref_nav_set base_value expression)
    string_take(expression "!")
    ans(create_path)

    navigation_expression_parse("${expression}")
    ans(expression)
    set(expression ${expression})

    set(current_value "${base_value}")
    set(current_ranges)
    set(current_property)
    set(current_ref)
    # this loop  navigates through existing values using ranges and properties as navigation expressions
    # the 4 vars declared before this comment will be defined
    while(true)
      list(LENGTH expression continue)
      if(NOT continue)
        break()
      endif()

      list_pop_front(expression)
      ans(current_expression)

      set(is_property true)
      if("${current_expression}" MATCHES "^[<>].*[<>]$")
        set(is_property false)
      endif()
   #   print_vars(current_expression is_property)
      if(is_property)

        map_isvalid("${current_value}")
        ans(is_ref)
        if(is_ref)
            set(current_ref "${current_value}")
            set(current_property "${current_expression}")
            set(current_ranges) 
        else()
          list_push_front(expression "${current_expression}")
          break()
        endif()

        ref_prop_get("${current_value}" "${current_expression}")
        ans(current_value)
      else()
        list_range_try_get(current_value "${current_expression}")
        ans(current_value)
        list(APPEND current_ranges "${current_expression}")
      endif()
    endwhile()



    set(value ${ARGN})
    
    # if the expressions are left and create_path is not specified
    # this will cause an error else the rest of the path is created
    list(LENGTH expression expression_count)
    if(expression_count GREATER 0)
      if(NOT create_path)
        message(FATAL_ERROR "could not find path ${expression}")
      endif()
      ref_nav_create_path("${expression}" ${value})
      ans(value)
    endif()

    ## get the last existing value
    if(current_ref)
      ref_prop_get("${current_ref}" "${current_property}")
      ans(current_value)
    else()
      set(current_value ${base_value})
    endif()

    ## if there are ranges set the interpret the value as a lsit and set the correct element
    list(LENGTH current_ranges range_count)
    if(range_count GREATER 0)
      list_range_partial_write(current_value "${current_ranges}" "${value}")
    else()
      set(current_value "${value}")
    endif()

    ## either return a new base balue or set the property of the last existing ref
    if(NOT current_ref)    
      set(base_value "${current_value}")
    else()
      ref_prop_set("${current_ref}" "${current_property}" "${current_value}")
    endif()

    return_ref(base_value)
  endfunction()





# creates a local variable for every key value pair in map
# if the optional prefix is given this will be prepended to the variable name
function(scope_import_map map)
	set(prefix ${ARGN})

	map_keys(${map})
	ans(keys)

	foreach(key ${keys})
		map_tryget(${map}  ${key})
		ans(value)
		set("${prefix}${key}" ${value} PARENT_SCOPE)
	endforeach()
endfunction()




# Exports the curretn scope of local variables into a map
function(scope_export_map)
  get_cmake_property(_variableNames VARIABLES)
  map_new()
  ans(_exportmapname)
  foreach (_variableName ${_variableNames})
    map_set("${_exportmapname}" "${_variableName}" "${${_variableName}}")
  endforeach()
  return_ref(_exportmapname)
endfunction()




# clears the current local scope of any variables
function(scope_clear)
  scope_keys()
  ans(vars)
  foreach (var ${vars})
    set(${var} PARENT_SCOPE)
  endforeach()
endfunction()




# print the local scope as json
function(scope_print)
  scope_export_map()
  ans(scope)
  json_print(${scope})
  return()
endfunction()






# returns all currently defined variables of the local scope
function(scope_keys)
  get_cmake_property(_variableNames VARIABLES)
  return_ref(_variableNames)
endfunction()







  ## queries a type
  function(query_type input_callback type)
    type_def("${type}")
    ans(type)

    map_tryget(${type} properties)
    ans(properties)

    list(LENGTH properties is_complex)

    if(NOT is_complex)
      query_fundamental("${input_callback}" "${type}")
      ans(res)
    else()
      query_properties("${input_callback}" "${type}")
      ans(res)      
    endif()
    return_ref(res)
  endfunction()  




# compiles a tool (single cpp file with main method)
# and create a cmake function (if the tool is not yet compiled)
# expects tool to print cmake code to stdout. this code will 
# be evaluated and the result is returned  by the tool function
# the tool function's name is name
# currently only allows default headers
function(compile_tool name src)
  checksum_string("${src}")
  ans(chksum)

  oocmake_config(temp_dir)
  ans(tempdir)


  set(dir "${temp_dir}/tools/${chksum}")

  if(NOT EXISTS "${dir}")

    pushd("${dir}" --create)
    fwrite("main.cpp" "${src}")
    fwrite("CMakeLists.txt" "
      project(${name})
      if(\"\${CMAKE_CXX_COMPILER_ID}\" STREQUAL \"GNU\")
        include(CheckCXXCompilerFlag)
        CHECK_CXX_COMPILER_FLAG(\"-std=c++11\" COMPILER_SUPPORTS_CXX11)
        CHECK_CXX_COMPILER_FLAG(\"-std=c++0x\" COMPILER_SUPPORTS_CXX0X)
        if(COMPILER_SUPPORTS_CXX11)
          set(CMAKE_CXX_FLAGS \"\${CMAKE_CXX_FLAGS} -std=c++11\")
        elseif(COMPILER_SUPPORTS_CXX0X)
          set(CMAKE_CXX_FLAGS \"\${CMAKE_CXX_FLAGS} -std=c++0x\")
        else()
                message(STATUS \"The compiler \${CMAKE_CXX_COMPILER} has no C++11 support. Please use a different C++ compiler.\")
        endif()

      endif()
      set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG   \${CMAKE_BINARY_DIR}/bin)
      set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE \${CMAKE_BINARY_DIR}/bin)
      set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG   \${CMAKE_BINARY_DIR}/lib)
      set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE \${CMAKE_BINARY_DIR}/lib)
      set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG   \${CMAKE_BINARY_DIR}/lib)
      set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE \${CMAKE_BINARY_DIR}/lib)
      set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY \${CMAKE_BINARY_DIR}/lib)
      set(CMAKE_LIBRARY_OUTPUT_DIRECTORY \${CMAKE_BINARY_DIR}/lib)
      set(CMAKE_RUNTIME_OUTPUT_DIRECTORY \${CMAKE_BINARY_DIR}/bin)
      add_executable(${name} main.cpp)
      ")
    mkdir(build)
    cd(build)
    cmake(../ --result)
    ans(configure_result)
    cmake(--build . --result)
    ans(build_result)


    map_tryget(${build_result} result)
    ans(error)
    map_tryget(${build_result} output)
    ans(log)
    popd()

    if(NOT "${error}" STREQUAL "0")        
      message(FATAL_ERROR "failed to compile tool :\n ${log}")
      rm("${dir}")
    endif()


  endif()
  
        
  wrap_executable("__${name}" "${dir}/build/bin/${name}")

  eval("
    function(${name})

      __${name}()
      ans(res)
      eval(\"\${res}\")
      return_ans()
    endfunction()
    ")



endfunction()




  function(parse_string rstring definition_id)
    # initialize
    if(NOT __parse_string_initialized)
      set(args ${ARGN})
      set(__parse_string_initialized true)
      list_extract(args definitions parsers language)
      function_import_table(${parsers} __call_string_parser)
    endif()

    # 
    map_get("${definitions}" "${definition_id}")
    ans(definition)
    
    #
    map_get("${definition}" parser)
    ans(parser_id)
    
    #
    #message(FORMAT "${parser_id} parser parsing ${definition_id}..")
    #message_indent_push()
    __call_string_parser("${parser_id}" "${rstring}")
    ans(res)
    #message_indent_pop()
    #message(FORMAT "${parser_id} parser returned: ${res} rest is ")
   #list(LENGTH res len)
 #  if(len)
   #  message("parsed '${res}' with ${parser_id} parser")
   #endif()   
    return_ref(res)
  endfunction()





  function(parse_match rstring)
    ref_get(${rstring})
    ans(str)

    map_get(${definition} search)
    ans(search)

    #message("parsing match with '${parser_id}' (search: '${search}') for '${str}'")
    map_tryget(${definition} ignore_regex)
    ans(ignore_regex)
   # message("ignore: ${ignore_regex}")
    list(LENGTH ignore_regex len)
    if(len)
     # message("ignoring ${ignore_regex}")
        string_take_regex(str "${ignore_regex}")
    endif()

    string_take(str "${search}")
    ans(match)

    if(NOT match)
      return()
    endif()

    ref_set(${rstring} "${str}")

    return_ref(match)
  endfunction()





function(parse_object rstring)
  
    # create a copy from rstring 
    ref_get(${rstring})
    ans(str)
    ref_setnew("${str}")
    ans(str)

    # get definitions
    map_tryget(${definition} begin)
    ans(begin_id)

    map_tryget(${definition} end)
    ans(end_id)
    
    map_tryget(${definition} keyvalue)
    ans(keyvalue_id)

    map_tryget(${definition} separator)
    ans(separator_id)         

    if(begin_id)
      parse_string(${str} ${begin_id})
      ans(res)
      list(LENGTH res len)
      if(${len} EQUAL 0)
        return()
      endif()
    endif()

    map_new()
    ans(result_object)

    set(has_result)

    while(true)
      # try to parse end of list if it was parsed stop iterating
      if(end_id)
        parse_string(${str} "${end_id}")
        ans(res)

        list(LENGTH res len)
        if(${len} GREATER 0)
          break()
        endif()
      endif()

      if(separator_id)
        if(has_result)
          parse_string(${str} "${separator_id}")
          ans(res)
          list(LENGTH res len)
          if(${len} EQUAL 0)
            if(NOT end)
              break()
            endif()
            return()
          endif()
        endif()
      endif()

      parse_string(${str} "${keyvalue_id}")
      ans(keyvalue)

      if(NOT keyvalue)
        if(NOT end)
          break()
        endif()
        return()
      endif()

      map_get(${keyvalue} key)
      ans(object_key)

      map_get(${keyvalue} value)
      ans(object_value)

      if(NOT has_result)
        set(has_result true)
      endif()

      if("${object_value}_" STREQUAL "_")
        
        set(object_value "")
      endif()
      
      map_set("${result_object}" "${object_key}" "${object_value}")

    endwhile()    


    # if every element was  found set rstring to rest of string
    ref_get(${str})
    ans(str)
    ref_set(${rstring} "${str}")

    # return result
    return_ref(result_object)
endfunction()





  function(parse_regex rstring)
    # deref rstring
    ref_get(${rstring})
    ans(str)
   # message("string ${str}")
    # get regex from defintion
    map_get(${definition} regex)
    ans(regex)
   # message("${regex}")

 #   message("parsing '${parser_id}' parser (regex: '${regex}') for '${str}'")
    # try to take regex from string
    
    map_tryget(${definition} ignore_regex)
    ans(ignore_regex)
   # message("ignore: ${ignore_regex}")
    list(LENGTH ignore_regex len)
    if(len)
   # message("ignoring ${ignore_regex}")
        string_take_regex(str "${ignore_regex}")
    endif()
#   message("str is '${str}'")
    string_take_regex(str "${regex}")
    ans(match)

    #message("match ${match}")
    # if not success return
    list(LENGTH match len)
    if(NOT len)
      return()
    endif()
 #   message("matched '${match}'")

    map_tryget(${definition} replace)
    ans(replace)
    if(replace)        
        string_eval("${replace}")
        ans(replace)
        #message("replace ${replace}")
        string(REGEX REPLACE "${regex}" "${replace}" match "${match}")
        #message("replaced :'${match}'")

    endif()

    map_tryget(${definition} transform)
    ans(transform)
    if(transform)
        #message("transforming ")
        call("${transform}"("match"))
        ans(match)
    endif()

    if("${match}_" STREQUAL "_")
        set(match "")
    endif()
    # if success set rstring to rest of string
    ref_set(${rstring} "${str}")

    # return matched element
    return_ref(match)
  endfunction()




  function(parse_any rstring)
    # get defintiions for any
    map_get(${definition} any)
    ans(any)

    ref_isvalid("${any}")
    ans(isref)
    if(isref)
      ref_get(${any})
      ans(any)
    endif()
    # loop through defintions and take the first one that works
    foreach(def_id ${any})
      parse_string("${rstring}" "${def_id}")
      ans(res)

      list(LENGTH res len)
      if("${len}" GREATER 0)
        return_ref(res)
      endif()

    endforeach()

    # return nothing if nothing matched
    return()
  endfunction()





 function(parse_ref rstring)
    ref_get(${rstring})
    ans(str)
    string_take_regex(str ":[a-zA-Z0-9_-]+")
    ans(match)
    if(NOT DEFINED match)
      return()
    endif()
  #  message("match ${match}")
    ref_isvalid("${match}")
    ans(isvalid)

    if(NOT  isvalid)
      return()
    endif()



    map_tryget(${definition} matches)
    ans(matches)
    #json_print(${matches})
    map_isvalid(${matches})
    ans(ismap)

    if(NOT ismap)
      ref_get(${match})
      ans(ref_value)

      if("${matches}" MATCHES "${ref_value}")
        return_ref(match)
      endif()
      return()
    else()
      map_keys(${matches})
      ans(keys)
      foreach(key ${keys})
        map_tryget(${match} "${key}")
        ans(val)

        map_tryget(${matches} "${key}")
        ans(regex)

        if(NOT "${val}" MATCHES "${regex}")
          return()
        endif()
      endforeach()
    endif()
    ref_set(${rstring} "${str}")
    return_ref(match)
  endfunction()





  function(parse_many rstring)
    map_tryget(${definition} begin)
    ans(begin)
    map_tryget(${definition} end)
    ans(end)
    map_tryget(${definition} element)
    ans(element)
    map_tryget(${definition} separator)
    ans(separator)         

    # create copy of input string
    ref_get(${rstring})
    ans(str)
    ref_setnew("${str}")
    ans(str)

    if(begin)
      parse_string(${str} ${begin})
      ans(res)
      list(LENGTH res len)
      if(${len} EQUAL 0)
        return()
      endif()
    endif()
    set(result_list)
    while(true)

      # try to parse end of list if it was parsed stop iterating
      if(end)
        parse_string(${str} ${end})
        ans(res)
        list(LENGTH res len)
        if(${len} GREATER 0)
          break()
        endif()
      endif()

      if(separator)
        if(result_list)
          parse_string(${str} ${separator})
          ans(res)
          list(LENGTH res len)
          if(${len} EQUAL 0)
            if(NOT end)
              break()
            endif()
            return()
          endif()
        endif()
      endif()

      parse_string("${str}" "${element}")
      ans(res)
      list(LENGTH res len)
      if(${len} EQUAL 0)
        if(NOT end)
          break()
        endif()
        return()
      endif()
      
      list(APPEND result_list "${res}")
    endwhile()    

    # set rstring
    ref_get(${str})
    ans(str)
    ref_set(${rstring} "${str}")
    
    list(LENGTH return_list len)
    if(NOT len)
      #return("")
    endif()
    return_ref(result_list)
  endfunction()






  function(parse_sequence rstring) 
    # create a copy from rstring 
    ref_get(${rstring})
    ans(str)
    ref_setnew("${str}")
    ans(str)

    # get sequence definitions
    map_get(${definition} sequence)
    ans(sequence)

    map_keys(${sequence})
    ans(sequence_keys)

    function(eval_sequence_expression rstring key res_map expression set_map)
      map_isvalid("${expression}")
      ans(ismap)

      if(ismap)
        map_new()
        ans(definition)

        map_set(${definition} "parser" "sequence")
        map_set(${definition} "sequence" "${expression}")
        
#        json_print(${definition})
        parse_sequence("${rstring}")
        ans(res)

        if("${res}_" STREQUAL "_")
          return(false)
        endif()

        map_set(${result_map} "${key}" ${res})
        map_set(${set_map} "${key}" true)
        return(true)

      endif()      



      #message("Expr ${expression}")
      if("${expression}" STREQUAL "?")
        return(true)
      endif()
      # static value
      if("${expression}" MATCHES "^@")
        string(SUBSTRING "${expression}" 1 -1 expression)
        map_set("${res_map}" "${key}" "${expression}")
        return(true)
      endif()
      
      # null coalescing
      if("${expression}" MATCHES "[^@]*\\|")
        string_split_at_first(left right "${expression}" "|")
        eval_sequence_expression("${rstring}" "${key}" "${res_map}" "${left}" "${set_map}")
        ans(success)
        if(success)
          return(true)
        endif()
       # message("parsing right")
        eval_sequence_expression("${rstring}" "${key}" "${res_map}" "${right}" "${set_map}")
        return_ans()
      endif()

      # ternary operator ? :
      if("${expression}" MATCHES "[a-zA-Z0-9_-]+\\?.+")
        string_split_at_first(left right "${expression}" "?")
        set(else)
        if(NOT "${right}" MATCHES "^@")
          string_split_at_first(right else "${right}" ":")
        endif()
        map_tryget(${set_map} "${left}")
        ans(has_value)
        if(has_value)
          eval_sequence_expression("${rstring}" "${key}" "${res_map}" "${right}" "${set_map}")
          ans(success)
          if(success)
            return(true)
          endif()
          return(false)
        elseif(DEFINED else)
          eval_sequence_expression("${rstring}" "${key}" "${res_map}" "${else}" "${set_map}")
          ans(success)
          if(success)
            return(true)
          endif()

          return(false)
        else()
          return(true)
        endif()

      endif() 



      set(ignore false)
      set(optional false)
      set(default)


      if("${expression}" MATCHES "^\\?")
        string(SUBSTRING "${expression}" 1 -1 expression)
        set(optional true)
      endif()
      if("${expression}" MATCHES "^/")
        string(SUBSTRING "${expression}" 1 -1 expression)
        set(ignore true)
      endif()


      parse_string("${rstring}" "${expression}")
      ans(res)

      list(LENGTH res len)


      if(${len} EQUAL 0 AND NOT optional)
        return(false)
      endif()

      if(NOT "${ignore}" AND DEFINED res)
   #     message("setting at ${key}")
        map_set("${res_map}" "${key}" "${res}")
      endif()
      
      if(NOT ${len} EQUAL 0)
        map_set(${set_map} "${key}" "true")

      endif()
      return(true)
    endfunction()

    # match every element in sequence
    map_new()
    ans(result_map)

    map_new()
    ans(set_map)


    foreach(sequence_key ${sequence_keys})

      map_tryget("${sequence}" "${sequence_key}")
      ans(sequence_id)

      eval_sequence_expression("${str}" "${sequence_key}" "${result_map}" "${sequence_id}" "${set_map}")
      ans(success)
      if(NOT success)
        return()
      endif()
    endforeach()




    # if every element was  found set rstring to rest of string
    ref_get(${str})
    ans(str)
    ref_set(${rstring} "${str}")

    # return result
    return_ref(result_map)
  endfunction()



#    foreach(sequence_key ${sequence_keys})
#
#      map_tryget("${sequence}" "${sequence_key}")
#      ans(sequence_id)
#
#      if("${sequence_id}" MATCHES "^@")
#        string(SUBSTRING "${sequence_id}" 1 -1 sequence_id)
#        map_set("${result_map}" "${sequence_key}" "${sequence_id}")
#     
#      else()
#        set(ignore false)
#        set(optional false)
#        if("${sequence_id}" MATCHES "^\\?")
#          string(SUBSTRING "${sequence_id}" 1 -1 sequence_id)
#          set(optional true)
#        endif()
#        if("${sequence_id}" MATCHES "^/")
#          string(SUBSTRING "${sequence_id}" 1 -1 sequence_id)
#          set(ignore true)
#        endif()
#
#
#        parse_string("${str}" "${sequence_id}")
#        ans(res)
#
#        list(LENGTH res len)
#
#
#        if(${len} EQUAL 0 AND NOT optional)
#          return()
#        endif()
#
#        if(NOT "${ignore}")
#          map_set("${result_map}" "${sequence_key}" "${res}")
#        endif()
#      endif()
#    endforeach()






function(shell_env_append key value)
  if(WIN32)
    shell("SETX ${key} %${key}%;${value}")

  else()
    message(WARNING "shell_set_env not implemented for anything else than windows")

  endif()
endfunction()





# 
function(shell_path_add path)
  set(args ${ARGN})
  list_extract_flag(args "--prepend")
  ans(prepend)

  shell_path_get()
  ans(paths)
  path("${path}")
  ans(path)
  list_contains(paths "${path}")
  ans(res)
  if(res)
    return(false)
  endif()


  if(prepend)
    set(paths "${path};${paths}")
  else()
    set(paths "${paths};${path}")
  endif()

  shell_path_set(${paths})

  return(true)
endfunction()






function(shell_env_prepend key value)

endfunction()





function(alias_exists name)
  alias_list()
  ans(aliases)
  list_contains(aliases "${name}")
  ans(res)
  return_ref(res)
endfunction()






# creates a temporary script file which contains the specified code
# and has the correct exension to be run with execute_process
# the path to the file will be returned
function(shell_tmp_script code)
  shell_get_script_extension()
  ans(ext)
  file_temp_name("{{id}}.${ext}")
  ans(tmp)
  shell_script_create("${tmp}" "${code}")
  ans(res)
  return_ref(res)
endfunction()




# creates a systemwide alias callend ${name} which executes the specified command_string
#  you have to restart you shell/re-login under windows for changes to take effect 
function(alias_create name command_string)


  if(WIN32)      
    oocmake_config(bin_dir)
    ans(bin_dir)

    set(path "${bin_dir}/${name}.bat")
    file_write("${path}" "@echo off\r\n${command_string} %*")
    reg_append_if_not_exists(HKCU/Environment Path "${bin_dir}")
    ans(res)
    if(res)
      #message(INFO "alias ${name} was created - it will be available as soon as you restart your shell")
    else()
      #message(INFO "alias ${name} as created - it is directly available for use")
    endif()
    return(true)
  endif()


  shell_get()
  ans(shell)

  if("${shell}" STREQUAL "bash")
    home_path(.bashrc)
    ans(bc)
    fappend("${bc}" "\nalias ${name}='${command_string}'")
    #message(INFO "alias ${name} was created - it will be available as soon as you restart your shell")

  else()
    message(FATAL_ERROR "creating alias is not supported by oocmake on your system your current shell (${shell})")
  endif()
endfunction()








# sets a system wide environment variable 
# the variable will not be available until a new console is started
function(shell_env_set key value)
  if(WIN32)
    reg_write_value("HKCU/Environment" "${key}" "${value}")
    #message("environment variable '${key}' was written, it will be available as soon as you restart your shell")
    return()
  endif()
  

  shell_get()
  ans(shell)
    
  if("${shell}" STREQUAL "bash")
    home_path(.bashrc)
    ans(path)
    fappend("${path}" "\nexport ${key}=${value}")
    #message("environment variable '${key}' was exported in .bashrc it will be available as soon as your restart your shell")
  else()
    message(WARNING "shell_set_env not implemented")
  endif()
endfunction()






# returns the extension for a shell script file on the current console
# e.g. on windows this returns bat on unix/bash this returns bash
# uses shell_get() to determine which shell is used
function(shell_get_script_extension)
  shell_get()
  ans(shell)
  if("${shell}" STREQUAL "cmd")
    return(bat)
  elseif("${shell}" STREQUAL "bash")
    return(sh)
  else()
    message(FATAL_ERROR "no shell could be recognized")
  endif()

endfunction()




function(shell_path_get)
    shell_env_get(Path)
    ans(paths)
    set(paths2)
    foreach(path ${paths})
      file(TO_CMAKE_PATH path "${path}")
      list(APPEND paths2 "${path}")
    endforeach()
    return_ans(paths2)

endfunction()






# fully qualifies the path into a unix path (even windows paths)
# transforms C:/... to /C/...
function(unix_path path)
  path("${path}")
  ans(path)
  string(REGEX REPLACE "^_([a-zA-Z]):\\/" "/\\1/" path "_${path}")
  return_ref(path)
endfunction()







# removes a system wide environment variable
function(shell_env_unset key)
  # set to nothing
  shell_env_set("${key}" "")
  shell_get()
  ans(shell)
  if("${shell}_" STREQUAL "cmd_")
    shell("REG delete HKCU\Environment /V ${key}")
  else()
    message(WARNING "shell_env_unset not implemented for anything else than windows")
  endif()
endfunction()





# returns the value of the shell's environment variable ${key}
function(shell_env_get key)
  shell_get()
  ans(shell)

  if(WIN32)
    
  endif()

  if("${shell}" STREQUAL "cmd")
    #setlocal EnableDelayedExpansion\nset val=\nset /p val=\necho %val%> \"${value_file}\"
    shell_redirect("echo %${key}%")
    ans(res)
  elseif("${shell}" STREQUAL "bash")
    shell_redirect("echo $${key}")
    ans(res)
  else()
    message(FATAL_ERROR "${shell} not supported")
  endif()


    # strip trailing '\n' which might get added by the shell script. as there is no way to input \n at the end 
    # manually this does not change for any system
    if("${res}" MATCHES "(\n|\r\n)+$")
      string(REGEX REPLACE "(\n|\r\n)+$" "" res "${res}")
    endif()
    
  return_ref(res)
endfunction()





# creates a shell script file containing the specified code and the correct extesion to execute
# with execute_process
function(shell_script_create path code)
  if(NOT ARGN)
    shell_get()
    ans(shell)
  else()
    set(shell "${ARGN}")
  endif()
  if("${shell}_" STREQUAL "cmd_")
    if(NOT "${path}" MATCHES "\\.bat$")
      set(path "${path}.bat")
    endif()
    set(code "@echo off\n${code}")
  elseif("${shell}_" STREQUAL "bash_")
    if(NOT "${path}" MATCHES "\\.sh$")
      set(path "${path}.sh")
    endif()
    set(code "#!/bin/bash\n${code}")
    touch("${path}")
    execute_process(COMMAND chmod +x "${path}")
  else()
    message(WARNING "shell not supported: '${shell}' ")
    return()
  endif()
    fwrite("${path}" "${code}")
    return_ref(path)
endfunction()





function(alias_list)

  path("${CMAKE_CURRENT_LIST_DIR}/../bin")
  ans(path)
  
  if(WIN32)
  file_extended_glob("${path}" "*.bat" "!cps.*" "!cutil.*")
  ans(cmds)
  set(theRegex "([^\\/])+\\.bat")
  list_select(cmds "(it)-> regex_search($it $theRegex 1)")
  ans(cmds)
  string(REPLACE ".bat" "" cmds "${cmds}")

  return_ref(cmds)
else()
  message(FATAL_ERROR "only implemented for windows")
endif()

endfunction()







# writes the args to console. does not append newline
function(echo_append)
  execute_process(COMMAND ${CMAKE_COMMAND} -E echo_append "${ARGN}")
endfunction()





function(alias_remove name)
  path("${CMAKE_CURRENT_LIST_DIR}/../bin")
  ans(path)
  if(WIN32)
    file(REMOVE "${path}/${name}.bat")
  else()
    message(FATAL_ERROR "only implemnted for windows")
  endif()

endfunction()





# writes the args to the console
function(echo)
  execute_process(COMMAND ${CMAKE_COMMAND} -E echo "${ARGN}")
endfunction()




# runs a shell script on the current platform
# not that
function(shell cmd)
  
  shell_get()
  ans(shell)
  if("${shell}" STREQUAL "cmd")
    file_tmp("bat" "@echo off\n${cmd}")
    ans(shell_script)
  elseif("${shell}" STREQUAL "bash")
    file_tmp("sh" "#!/bin/bash\n${cmd}")
    ans(shell_script)
    # make script executable
    execute_process(COMMAND "chmod" "+x" "${shell_script}")

  endif()

  # execute shell script which write the keyboard input to the ${value_file}
  set(args ${ARGN})

  list_extract_flag(args --result)
  ans(result_flag)

  execute("{
    path:$shell_script,
    args:$args
    }")
  ans(res)

  # remove temp file
  file(REMOVE "${shell_script}")
  if(result_flag)
    return_ref(res)
  endif()

  map_tryget(${res} result)
  ans(return_code)

  if(NOT "_${return_code}" STREQUAL "_0")
    return()
  endif()

  map_tryget(${res} output)
  ans(output)
  return_ref(output)
endfunction()





# redirects the output of the specified shell to the result value of this function
function(shell_redirect code)
  file_tmp("txt" "")
  ans(tmp_file)
  shell("${code}> \"${tmp_file}\"")
  fread("${tmp_file}")
  ans(res)
  file(REMOVE "${tmp_file}")
  return_ref(res)
endfunction()






function(shell_path_set)
  set(args ${ARGN})
  if(WIN32)
    string(REPLACE "\\\\" "\\" args "${args}")
  endif()
  message("setting path ${args}")
  shell_env_set(Path "${args}")
  return()
endfunction()








#C:\ProgramData\Oracle\Java\javapath;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Program Files (x86)\ATI Technologies\ATI.ACE\Core-Static;C:\Program Files (x86)\Windows Kits\8.1\Windows Performance Toolkit\;C:\Program Files\Microsoft SQL Server\110\Tools\Binn\;C:\Program Files (x86)\Git\cmd;C:\Program Files\Mercurial\;C:\Program Files\nodejs\;C:\Program Files (x86)\Microsoft SDKs\TypeScript\1.0\;C:\Program Files\Microsoft SQL Server\120\Tools\Binn\
#C:\ProgramData\chocolatey\bin;C:\Program Files\Mercurial;C:\Users\Tobi\AppData\Roaming\npm


# creates the bash string using the map env which contains key value pairs
function(bash_profile_compile env)
  set(res)
  map_keys(${env})
  ans(keys)
  foreach(key ${keys})
    map_tryget(${env} ${key})
    ans(val)
    set(res "${res}export ${key}=\"${val}\"\n")
  endforeach()
  return_ref(res)
endfunction()

# creates and writes the bash profile env to path (see bash_profile_compile)
function(bash_profile_write path env)
  bash_profile_compile(${env})
  ans(str)
  bash_script_create("${path}" "${str}")
  return_ans()
endfunction()

function(bash_autostart_read)
  set(session_profile_path "$ENV{HOME}/.profile")
  if(NOT EXISTS "${session_profile_path}")
    return()
  endif()
  fread("${session_profile_path}")
  ans(res)
  return_ref(res)
endfunction()

# registers
function(bash_autostart_register)
  set(session_profile_path "$ENV{HOME}/.profile")
  if(NOT EXISTS "${session_profile_path}")
    touch("${session_profile_path}")
  endif()
  fread("${session_profile_path}")
  ans(profile)

  set(profile_path "$ENV{HOME}/oocmake.profile.sh")

  if(NOT EXISTS "${profile_path}")
    shell_script_create("${profile_path}" "")
  endif()

  if("${profile}" MATCHES "${profile_path}\n")
    return()
  endif()

  unix_path("${profile_path}")
  ans(profile_path)
  set(profile "${profile}\n${profile_path}\n")
  fwrite("${session_profile_path}" "${profile}")

  return()
endfunction()

# removes the cmake profile from $ENV{HOME}/.profile
function(bash_autostart_unregister)
  set(session_profile_path "$ENV{HOME}/.profile")
  if(NOT EXISTS "${session_profile_path}")
    return()
  endif()
  fread("${session_profile_path}")
  ans(content)
  string_regex_escape("${session_profile_path}")
  ans(escaped)
  string(REGEX REPLACE "${escaped}" "" content "${content}")
  fwrite("${session_profile_path}" "${content}")
  return()
endfunction()


# returs true if the oocmake session profile (environment variables)are registered
function(bash_autostart_isregistered)
  set(session_profile_path "$ENV{HOME}/.profile")
  if(NOT EXISTS "${session_profile_path}")
    return(false)
  endif()
  fread("${session_profile_path}")
  ans(content)
  string_regex_escape("${session_profile_path}")
  ans(escaped)
  if("${content}" MATCHES "${escaped}")
    return(true)
  endif()
  return(false)
endfunction()










# returns a filename which does not exist yet
# you need to pass a filter which contains the stirng {id}
# id will be varied untikl a file is found which does not exist
# the complete path will be returned
function(file_temp_name template)
  oocmake_config(temp_dir)
  ans(temp_dir)
  file_random( "${temp_dir}/${template}")
  ans(rnd)
  return_ref(rnd)
endfunction()






# returns which shell is used (bash,cmd) returns false if shell is unknown
function(shell_get)
  if(WIN32)
    return(cmd)
  else()
    return(bash)
  endif()

endfunction()










# reads a line from the console.  
#  uses .bat file on windows else uses shell script file .sh
function(read_line)
  file_tmp("txt" "")
  ans(value_file)

  if(WIN32)
    # thanks to Fraser999 for fixing whis to dissallow variable expansion and whitespace stripping
    # etc. See merge comments
    file_tmp("bat" "@echo off\nsetlocal EnableDelayedExpansion\nset val=\nset /p val=\necho !val!> \"${value_file}\"")
    ans(shell_script)
  else()
    file_tmp("sh" "#!/bin/bash\nread text\necho -n $text>${value_file}")
    ans(shell_script)
    # make script executable
    execute_process(COMMAND "chmod" "+x" "${shell_script}")
  endif()

  # execute shell script which write the keyboard input to the ${value_file}
  execute_process(COMMAND "${shell_script}")

  # read value file
  file(READ "${value_file}" line)

  # strip trailing '\n' which might get added by the shell script. as there is no way to input \n at the end 
  # manually this does not change for any system
  if("${line}" MATCHES "(\n|\r\n)$")
    string(REGEX REPLACE "(\n|\r\n)$" "" line "${line}")
  endif()

  ## quick fix
  if("${line}" STREQUAL "ECHO is off.")
    set(line)
  endif()
  # remove temp files
  file(REMOVE "${shell_script}")
  file(REMOVE "${value_file}")
  return_ref(line)
endfunction()







function(shell_path_remove path)
  shell_path_get()
  ans(paths)

  path("${path}")
  ans(path)

  list_contains(paths "${path}")
  ans(res)
  if(res)
    list_remove(paths "${path}")
    shell_path_set(${paths})
    return(true)
  else()
    return(false)
  endif()

endfunction()




  ## waits until any of the specified handles stops running
  ## returns the handle of that process
  ## if --timeout <n> is specified function will return nothing after n seconds
  function(process_wait_any)
    set(args ${ARGN})
    list_extract_flag(args --quietly)
    ans(quietly)    

    process_handles(${args})
    ans(processes)


    if(NOT quietly)
      list(LENGTH processes len)
      echo_append("waiting for any of ${len} processes to finish.")  
    endif()

    set(timeout_process_handle)
    if(timeout)
      process_timeout(${timeout})
      ans(timeout_process_handle)
      list(APPEND processes ${timeout_process_handle})
    endif()

    while(processes)
      list_pop_front(processes)
      ans(process)
      process_refresh_handle(${process})
      ans(isrunning)


      if(NOT quietly)
        tick()
      endif()

      if(NOT isrunning)
        if("${process}_" STREQUAL "${timeout_process_handle}_")      
          echo(".. timeout")
          return()
        endif()
        if(NOT quietly)
          echo("")
        endif()
        return(${process})
      else()
        list(APPEND processes ${process})
      endif()

    endwhile()   
  endfunction()




# wraps the win32 console executable cmd.exe
function(win32_cmd)
  wrap_executable(win32_cmd cmd.exe)
  win32_cmd(${ARGN})
  return_ans()
endfunction()





  ## runs the specified code as a powershell script
  ## and returns the result
  function(win32_powershell_run_script code)
    mktemp()
    ans(path)

    fwrite("${path}/script.ps1" "${code}")
    ans(script_file)
    win32_powershell(
      -NoLogo                   # no info output 
      -NonInteractive           # no interaction
      -ExecutionPolicy ByPass   # bypass execution policy 
      -WindowStyle Hidden       # hide window
      -File "${script_file}"    # the file to execute
      ${ARGN}                   # add further args to command line
      )
    return_ans()
  endfunction()





## windows implementation for start process
 function(process_start_Windows)
    process_start_info(${ARGN})
    ans(start_info)

    if(NOT start_info)
      message(WARNING "<process start info> could not be parsed from '${ARGN}'")
      return()
    endif()

    map_tryget(${start_info} command)
    ans(command)

    map_tryget(${start_info} args)
    ans(args)

    map_tryget(${start_info} cwd)
    ans(cwd)

    ## create temp dir where process specific files are stored
    mktemp()
    ans(dir)

    ## files where to store stdout and stderr
    set(outputfile "${dir}/stdout.txt")
    set(errorfile "${dir}/stderr.txt")
    set(returncodefile "${dir}/retcode.txt")
    set(pidfile "${dir}/pid.txt")
    fwrite("${outputfile}" "")
    fwrite("${errorfile}" "")
    fwrite("${returncodefile}" "")

    ## compile arglist
    win32_powershell_create_array(${args})
    ans(arg_list)

    ## The following script is a bit complex but it has to be to get the commands 
    ## pid,stdout, stderr and return_code correctly
    ## two instances of powershell need to be started for this to work correctly

    ## innerscript which starts the process  in ${cwd} using powershell's start-process command
    ## with redirected error and output streams
    ## it immediately writes the process id to ${pidfile}
    ## then it waits for process to finish
    ## after which it parses the exit code of said process
    set(inner "
      $j = start-process  -filepath '${command}'  -argumentlist ${arg_list} -passthru -redirectstandardout '${outputfile}' -redirectstandarderror '${errorfile}' -workingdirectory '${cwd}'
      $handle = $j.handle
      echo $j.id | out-file -encoding ascii -filepath '${pidfile}'
      wait-process -id $j.id
      $code = '[DllImport(\"kernel32.dll\")] public static extern int GetExitCodeProcess(IntPtr hProcess, out Int32 exitcode);'
      $type = Add-Type -MemberDefinition $code -Name \"Win32\" -Namespace Win32 -PassThru
      [Int32]$exitCode = 0
      $type::GetExitCodeProcess($j.Handle, [ref]$exitCode)
      echo $exitCode | out-file -encoding ascii -filepath '${returncodefile}'
      ")
    ## store innerscript so it can be called by outer script  
    fwrite("${dir}/inner.ps1" "${inner}")
    ans(inner_script)

    ## starts a new powershell process executing  the innerscript and exits 
    ## this wrapping is needed because redirectstandarderror and redirectstandardout 
    ## will cause powershell to wait for the stream to end which happens when the process is finished.
    ## hides the window 
    ## on execution you will notice that two windows open in quick succession
    set(outer "
        start-process -WindowStyle Hidden -filepath powershell -argumentlist @('-NoLogo','-NonInteractive','-ExecutionPolicy','ByPass','-WindowStyle','Hidden','-File','${inner_script}')
        exit
      ")

    ## run script
    win32_powershell_run_script("${outer}")    
    ans(pid)

    ## wait until the pidfile exists and contains a valid pid
    ## this seems very hackisch but is necessary as i have not found
    ## a simpler way to do it
    while(true)
      if(EXISTS "${pidfile}")
        fread("${pidfile}")
        ans(pid)
        if("${pid}" MATCHES "[0-9]+" )
          break()
        endif()
      endif()
    endwhile()


    ## create a process handle from pid
    process_handle("${pid}")    
    ans(handle)

    
    ## set the output files for handle
    nav(handle.stdout_file = outputfile)
    nav(handle.stderr_file = errorfile)
    nav(handle.return_code_file = returncodefile)
    nav(handle.process_start_info = start_info)
    nav(handle.windows.process_data_dir = dir) 


    return_ref(handle)
  endfunction()


## old implementation with wmic
## does nto handle output and 
# function(process_start_Windows)
#   process_start_info(${ARGN})
#   ans(process_start_info)

#   if(NOT process_start_info)
#     return()
#   endif()

#   command_line_to_string(${process_start_info})
#   ans(command_line)
  
#   win32_fork(-exec "${command_line}" -workdir "${cwd}" --result)
#   ans(exec_result)
#   scope_import_map(${exec_result})
#   if(return_code)
#     json_print(${exec_result})
#     message(FATAL_ERROR "failed to fork process.  returned code was ${return_code} message:\n ${stdout}  ")
#   endif()

#   string(REGEX MATCH "[1-9][0-9]*" pid "${stdout}")
#   set(status running)
#   map_capture_new(pid process_start_info status)
#   return_ans()  
# endfunction()





# wraps the win32 taskkill command
function(win32_taskkill)
  wrap_executable(win32_taskkill "taskkill")
  win32_taskkill(${ARGN})
  return_ans()
endfunction()





## creates a  powershell array from the specified args
function(win32_powershell_create_array)

    ## compile powershell array for argument list
    set(arg_list)
    foreach(arg ${ARGN})
      string_encode_delimited("${arg}" \")
      ans(arg)
      list(APPEND arg_list "${arg}")
    endforeach()
    string_combine("," ${arg_list})
    ans(arg_list)
    set("${arg_list}" "@(${arg_list})")

    return_ref(arg_list)

endfunction()






## windows specific implementation for process_info
function(process_info_Windows handlish)
  process_handle("${handlish}")
  ans(handle)
  map_tryget(${handle} pid)
  ans(pid)


  win32_tasklist(/V /FO CSV /FI "PID eq ${pid}" --result )
  ans(exe_result)

  map_tryget(${exe_result} return_code)
  ans(error)
  if(error)
    return()
  endif()


  map_tryget(${exe_result} output)
  ans(csv)

  csv_deserialize("${csv}" --headers)  
  ans(res)

  map_rename(${res} PID pid)

  return_ref(res)
endfunction()








## platform specific implementation for process_list under windows
function(process_list_Windows)
  win32_wmic(process where "processid > 0" get processid) #ignore idle process
  ans(ids)

  string(REGEX MATCHALL "[0-9]+" matches "${ids}")
  set(ids)
  foreach(id ${matches})
    process_handle("${id}")
    ans(handle)
    list(APPEND ids ${id})
  endforeach()

  return_ref(ids)


endfunction()





## platform specific implementation for process_isrunning under windows
function(process_isrunning_Windows handlish)    
  process_handle("${handlish}")    
  ans(handle)    
  map_tryget(${handle} state)
  ans(state)
  if("${state}_" STREQUAL "terminated_" )
    return(false)
  endif()

  map_tryget(${handle} pid)
  ans(pid)
  
  win32_tasklist(-FI "PID eq ${pid}" -FI "STATUS eq Running")    
  ans(res)
  if("${res}" MATCHES "${pid}")
    return(true)
  endif()
  return(false)
endfunction()




#wraps the windows 32 for script which starts a new executable in a separate process and returns the PID
function(win32_fork)
  oocmake_config(base_dir)
  ans(base_dir)
  wrap_executable(win32_fork "${base_dir}/resources/exec_windows.bat")
  win32_fork(${ARGN})
  return_ans()
endfunction()





# windows implementation for process kill
function(process_kill_Windows process_handle)
  process_handle("${process_handle}")
  map_tryget(${process_handle} pid)
  ans(pid)

  win32_taskkill(/PID ${pid} --result)
  ans(res)
  scope_import_map(${res})
  if(error_code)
    return(false)
  endif()
  return(true)
endfunction()





## wraps the windows wmic command (windows XP and higher )
# since wmic does outputs unicode and does not take forward slash paths the usage is more complicated 
# and wrap_executable does not work
function(win32_wmic)
  pwd()
  ans(pwd)
  file_make_temporary("")
  ans(tmp)
  file(TO_NATIVE_PATH "${tmp}" out)

  execute_process(COMMAND wmic /output:${out} ${ARGN} RESULT_VARIABLE res WORKING_DIRECTORY "${pwd}")  
  if(NOT "${res}" EQUAL 0 )
    return()
  endif()

  fread_unicode16("${tmp}")        
  return_ans()
endfunction()





## wraps the windows task lisk programm which returns process info
function(win32_tasklist)
  wrap_executable(win32_tasklist "tasklist")
  win32_tasklist(${ARGN})
  return_ans()
endfunction()




# wraps the the win32 bash shell if available (Cygwin)
function(win32_bash)
  find_package(Cygwin )
  if(NOT Cygwin_FOUND)
    message(FATAL_ERROR "Cygwin was not found on your system")
  endif()
  wrap_exectuable(win32_bash "${Cygwin_EXECUTABLE}")
  win32_bash(${ARGN})
  return_ans()
endfunction()





# returns a <process handle>
# currently does not play well with arguments
function(win32_wmic_call_create command)
  path("${command}")
  ans(cmd)
  pwd()
  ans(cwd)  
  set(args)


  message("cmd ${cmd}")
  file(TO_NATIVE_PATH "${cwd}" cwd)
  file(TO_NATIVE_PATH "${cmd}" cmd)


  if(ARGN)
    string(REPLACE ";" " " args "${ARGN}")
    set(args ",${args}")
  endif()
  win32_wmic(process call create ${cmd},${cwd})#${args}
  ans(res)
  set(pidregex "ProcessId = ([1-9][0-9]*)\;")
  set(retregex "ReturnValue = ([0-9]+)\;")
  string(REGEX MATCH "${pidregex}" pid_match "${res}")
  string(REGEX MATCH "${retregex}" ret_match "${res}")

  string(REGEX REPLACE "${retregex}" "\\1" ret "${ret_match}")
  string(REGEX REPLACE "${pidregex}" "\\1" pid "${pid_match}")
  if(NOT "${ret}" EQUAL 0)
    return()
  endif() 
  process_handle(${pid})
  ans(res)
  map_set(${res} status running)
  return_ref(res)
endfunction()





  ## wraps the win32 powershell command
  function(win32_powershell)
    wrap_executable(win32_powershell PowerShell)
    win32_powershell(${ARGN})
    return_ans()
  endfunction()





## returns a list of <process info> containing all processes currently running on os
## process_list():<process info>...
function(process_list)
  wrap_platform_specific_function(process_list)
  process_list(${ARGN})
  return_ans()
endfunction()





## returns the <return_code> for the specified process handle
## if process is not finished the result is empty
  function(process_return_code handle)
    process_handle("${handle}")
    ans(handle)
    map_tryget("${handle}" return_code_file)
    ans(return_code_file)
    fread("${return_code_file}")
    ans(return_code)
    string(STRIP "${return_code}" return_code)
    return_ref(return_code)
  endfunction()





# wraps the linux ps command into an executable 
function(linux_ps)
  wrap_executable(linux_ps ps)
  linux_ps(${ARGN})
  return_ans()
endfunction()





## process_info implementation for linux_ps
## currently only returns the process command name
function(process_info_Linux handle)
  process_handle("${handle}")
  ans(handle)

  map_tryget(${handle} pid)
  ans(pid)
  

  linux_ps_info_capture(${pid} ${handle} comm)


  return_ref(handle)    
endfunction()






# wraps the bash executable in cmake
function(bash)
  wrap_executable(bash bash)
  bash(${ARGN})
  return_ans()
endfunction()





function(linux_ps_info pid key)
  linux_ps(-p "${pid}" -o "${key}=" --result)
  ans(res)

  map_tryget(${res} return_code)
  ans(return_code)
  if(NOT "${return_code}" EQUAL 0)

    return()
  endif()
  map_tryget(${res} output)
  ans(stdout)

  string(STRIP "${stdout}" val)
  return_ref(val)
endfunction()





function(linux_ps_info_get pid)
  map_new()
  ans(map)
  linux_ps_info_capture("${pid}" "${map}" ${ARGN})
  return("${map}")

endfunction()







  ## platform specific implementaiton for process_kill
  function(process_kill_Linux handle)
    process_handle("${handle}")
    ans(handle)

    map_tryget(${handle} pid)
    ans(pid)

    linux_kill(-SIGTERM ${pid} --result)
    ans(res)

    map_tryget(${res} return_code)
    ans(return_code)

    return_truth("${return_code}" EQUAL 0)
  endfunction() 






  ## wraps the linux pkill command
  function(linux_kill)
    wrap_executable(linux_kill kill)
    linux_kill(${ARGN})
    return_ans()
  endfunction()





function(nohup)
    wrap_executable(nohup nohup)
    nohup(${ARGN})
    return_ans()
endfunction()






# process_fork implementation specific to linux
# uses bash and nohup to start a process 
function(process_start_Linux)
    process_start_info(${ARGN})
    ans(process_start_info)

    if(NOT process_start_info)
      return()
    endif()

    scope_import_map(${process_start_info})

    command_line_args_combine(${args})
    ans(arg_string)
    set(command_string "${command} ${arg_string}")
  



    # define output files        
      file_make_temporary("")
      ans(stdout)
      file_make_temporary("")
      ans(stderr)
      file_make_temporary("")
      ans(return_code)
      file_make_temporary("")
      ans(pid_out)

      # create a temporary shell script 
      # which starts bash with the specified command 
      # output of the command is stored in stdout file 
      # error of the command is stored in stderr file 
      # return_code is stored in return_code file 
      # and the created process id is stored in pid_out
      shell_tmp_script("( bash -c \"${command_string} > ${stdout} 2> ${stderr}\" ; echo $? > ${return_code}) & echo $! > ${pid_out}")
      ans(script)
      ## execute the script in bash with nohup 
      ## which causes the script to run detached from process
      bash(-c "nohup ${script} > /dev/null 2> /dev/null" --return_code)
      ans(error)

      if(error)
        message(FATAL_ERROR "could not start process '${command_string}'")
      endif()

      fread("${pid_out}")
      ans(pid)

      string(STRIP "${pid}" pid)

    process_handle("${pid}")
    ans(handle)

    ## set output of process
    nav(handle.stdout_file = stdout)
    nav(handle.stderr_file = stderr)
    nav(handle.return_code_file = return_code)

    process_refresh_handle("${handle}")

    return_ref(handle)
endfunction()






function(process_isrunning_Linux handle)
  process_handle("${handle}")
  ans(handle)
  map_tryget(${handle} pid)
  ans(pid)
  linux_ps_info(${pid} pid)
  ans(val)
  if(NOT "${val}_" STREQUAL "${pid}_")
    return(false)
  endif()
  return(true)
endfunction()




# linux specific implementation of process_list 
# returns a list of <process handle> which only contains pid


  function(process_list_Linux)

    linux_ps()
    ans(res)

    string_lines("${res}")
    ans(lines)

    list_pop_front(lines)
    ans(headers)

    set(handles)
    set(ps_regex " *([1-9][0-9]*)[ ]*")
    #set(ps_regex " *([1-9][0-9]*)[ ]*([^ ]+)[ ]*([0-9][0-9]):([0-9][0-9]):([0-9][0-9]) *([^ ].*)")
    foreach(line ${lines})
      string(REGEX REPLACE "${ps_regex}" "\\1" pid "${line}")
      #string(REGEX REPLACE "${ps_regex}" "\\2" tty "${line}")
      #string(REGEX REPLACE "${ps_regex}" "\\3" hh "${line}")
      #string(REGEX REPLACE "${ps_regex}" "\\4" mm "${line}")
      #string(REGEX REPLACE "${ps_regex}" "\\5" ss "${line}")
      #string(REGEX REPLACE "${ps_regex}" "\\6" cmd "${line}")
      #string(STRIP "${cmd}" cmd)

      process_handle("${pid}")
      ans(handle)
      #map_capture(${handle} tty hh mm ss cmd) 
      
      list(APPEND handles ${handle})
    endforeach()
    return_ref(handles)
  endfunction()






function(linux_ps_info_capture pid map)

  foreach(key ${ARGN})
    linux_ps_info("${pid}" "${key}")
    ans(val)
    map_set(${map} "${key}" "${val}")

  endforeach()
  return()
endfunction()





## returns the runtime unique process handle
## information may differ depending on os but the following are the same for any os
## * pid
## * status
function(process_handle handlish)
  map_isvalid("${handlish}")
  ans(ismap)

  if(ismap)
    set(handle ${handlish})
  elseif( "${handlish}" MATCHES "[0-9]+")
    string(REGEX MATCH "[0-9]+" handlish "${handlish}")

    map_tryget(__process_handles ${handlish})
    ans(handle)
    if(NOT handle)
      map_new()
      ans(handle)
      map_set(${handle} pid "${handlish}")          
      map_set(${handle} state "unknown")
      map_set(__process_handles ${handlish} ${handle})
    endif()
  else()
    message(FATAL_ERROR "'${handlish}' is not a valid <process handle>")
  endif()
  return_ref(handle)
endfunction()





## process_info(<process handle?!>): <process info>
## returns information on the specified process handle
function(process_info)
  wrap_platform_specific_function(process_info)
  process_info(${ARGN})
  return_ans()
endfunction()





## escapes a command line quoting arguments as needed 
function(command_line_args_escape) 
  set(whitespace_regex "( )")
  set(result)
  
  string(ASCII  31 us)

  foreach(arg ${ARGN})
    string(REGEX MATCH "[\r\n]" m "${arg}")
    if(NOT "_${m}" STREQUAL "_")
      message(FATAL_ERROR "command line argument '${arg}' is invalid - contains CR NL - consider escaping")
    endif()

    string(REGEX MATCH "${whitespace_regex}|\"" m "${arg}")
    if("${arg}" MATCHES "${whitespace_regex}|\"")
      string(REPLACE "\"" "\\\"" arg "${arg}")
      set(arg "\"${arg}\"")
    elseif("${arg}" MATCHES "${us}")
      set(arg "\"${arg}\"")
    endif()




    list(APPEND result "${arg}")

  endforeach()    
  return_ref(result)
endfunction()





## starts a process and returns a handle which can be used to controll it.  
##
# {
#   <pid:<unique identifier>> // some sort of unique identifier which can be used to identify the processs
#   <process_start_info:<process start info>> /// the start info for the process
#   <output:<function():<string>>>
#   <status:"running"|"complete"> // indicates weather the process is complete - this is a cached result because query the process state is expensive
# }
function(process_start)
  wrap_platform_specific_function(process_start)
  process_start(${ARGN})
  return_ans()
endfunction()








function(command_line)
  map_isvalid("${ARGN}")
  ans(ismap)
  if(ismap)
    map_has("${ARGN}" command)
    ans(iscommand_line)
    if(iscommand_line)
      return("${ARGN}")
    endif()
    return()
  endif()
  command_line_parse(${ARGN})
  return_ans()


endfunction()




## command_line_parse 
## parses the sepcified cmake style  command list which starts with COMMAND 
## or parses a single command line call
## returns a command line object:
## {
##   command:<string>,
##   args: <string>...
## }
function(command_line_parse)
  set(args ${ARGN})

  if(NOT args)
    return()
  endif()


  list_pop_front(args)
  ans(first)

  list(LENGTH args arg_count)

  if("${first}_" STREQUAL "COMMAND_")
    list_pop_front(args)
    ans(command)

    command_line_args_combine(${args})
    ans(arg_string)


    set(command_line "\"${command}\" ${arg_string}")      
  else()
    if(arg_count)
     message(FATAL_ERROR "either use a single command string or a list of 'COMMAND <command> <arg1> <arg2> ...'")
    endif()
    set(command_line "${first}")
  endif()


  command_line_parse_string("${command_line}")
  return_ans()
endfunction()




# process_kill(<process handle?!>)
# stops the process specified by <process handle?!>
# returns true if the process was killed successfully
function(process_kill)
  wrap_platform_specific_function(process_kill)
  process_kill(${ARGN})
  return_ans()
endfunction()





function(test)
  # real world example


  ## define a function which downloads  
  ## all urls specified to the current dir
  ## returns the path for every downloaded files
  function(download_files_parallel)
    ## get current working dir
    pwd()
    ans(target_dir)

    ## process start loop 
    ## starts a new process for every url to download
    set(handles)
    foreach(url ${ARGN})
      ## start download by creating a cmake script
      process_start_script("
        include(${oocmake_base_dir}/cmakepp.cmake) # include oocmake
        download(\"${url}\" \"${target_dir}\")
        ans(result_path)
        message(STATUS ${target_dir}/\${result_path})
        ")
      ans(handle)
      ## store process handle 
      list(APPEND handles ${handle})
    endforeach()

    ## wait for all downloads to finish
    process_wait_all(${handles})

    set(result_paths)
    foreach(handle ${handles})
      ## get process stdout
      process_stdout(${handle})
      ans(output)

      ## remove '-- ' from beginning of output which is
      ## automatically prependend by message(STATUS) 
      string(SUBSTRING "${output}" 3 -1 output)

      ## store returned file path
      list(APPEND result_paths ${output})

    endforeach()

    ## return file paths of downloaded files
    return_ref(result_paths)
  endfunction()


  ## create and goto ./download_dir
  cd("download_dir" --create)

  ## start downloading files in parallel
  download_files_parallel(
    http://www.cmake.org/files/v3.0/cmake-3.0.2.tar.gz
    http://www.cmake.org/files/v2.8/cmake-2.8.12.2.tar.gz
  )
  ans(paths)


  assert(paths)

endfunction()




## combines the list of command line args into a string which separates and escapes them correctly
  function(command_line_args_combine)
    command_line_args_escape(${ARGN})
    ans(args)
    string_combine(" " ${args})
    ans(res)
    string_semicolon_decode("${res}")
    ans(res)
    
    return_ref(res)
  endfunction()






  ## process_wait_all(<handles: <process handle...>> <?"--quietly"> <?"--timeout":<seconds>>)
  ## waits for all specified <handles> to finish
  ## specify --quietly to supress output
  ## if --timeout <n> is specified the function will return all finished processes after n seconds
  function(process_wait_all)
    set(args ${ARGN})

    list_extract_flag(args --quietly)
    ans(quietly)   

    list_extract_labelled_value(args --timeout)
    ans(timeout)
    set(timeout_task_handle)
  

    process_handles(${args})
    ans(processes)


    list(LENGTH processes running_processes)
    set(process_count ${running_processes})
    if(NOT quietly)
      echo_append("waiting for ${running_processes} processes to complete.")
    endif()

    set(timeout_process_handle)
    if(timeout)
      process_timeout(${timeout})
      ans(timeout_process_handle)
      list(APPEND processes ${timeout_process_handle})
    endif()

    while(processes)
      list_pop_front(processes)
      ans(process)
      process_refresh_handle(${process})
      ans(isrunning)
      
      #message(FORMAT "{process.pid} isrunning {isrunning} {process.state} ")
      if(NOT quietly)
        tick()
      endif()

      if(NOT isrunning)
        if("${process}_" STREQUAL "_${timeout_process_handle}")
          set(processes)
          if(NOT quietly)
            echo_append(".. timeout")
          endif()
        else()           
          list(APPEND finished ${process})          
          if(NOT quietly)
            list(LENGTH finished finished_count)            
            echo_append("..${finished_count}/${process_count}")
          endif() 
        endif()        
      else()
        ## insert into back
        list(APPEND processes ${process})
      endif()
    endwhile()
    if(NOT quietly)
      echo()
    endif()
    return_ref(finished)
  endfunction()





function(command_line_to_string)
    command_line(${ARGN})
    ans(cmd)

    scope_import_map(${cmd})

    command_line_args_combine(${args})
    ans(arg_string)
    if(NOT "${arg_string}_" STREQUAL "_")
      set(arg_string " ${arg_string}")
    endif()
    set(command_line "${command}${arg_string}")
    return_ref(command_line)
  endfunction()


  





  ## blocks until given process has terminated
  ## returns nothing if the process does not exist - is deleted etc
  ## updates and returns the process_handle
  ## if a timeout greater 0 the function will return nothing if the timeout is reached
  ## process_wait(<process handle> <?--timeout:<seconds>>)
  function(process_wait handle)
    process_handle("${handle}")
    ans(handle)

    set(args ${ARGN})
    list_extract_labelled_value(args --timeout)
    ans(timeout)

    if("${timeout}_" STREQUAL "_")
      set(timeout -1)
    endif()

    if("${timeout}" LESS 0)
      while(true)

        process_refresh_handle(${handle})
        ans(isrunning)
        if(NOT isrunning)
          return(${handle})
        endif()
      endwhile()
    elseif("${timeout}" EQUAL 0)
      process_refresh_handle(${handle})
      ans(isrunning)
      if(isrunning)
        return()
      else()
        return("${handle}")
      endif()
    else()
      process_timeout(${timeout})
      ans(timeout_handle)
      while(true)
        process_refresh_handle(${handle})
        ans(isrunning)
        if(NOT isrunning)
          process_kill(${timeout_handle})
          return(${handle})
        endif()
        process_refresh_handle(${timeout_handle})
        ans(isrunning)
        if(NOT isrunning)
          return()
        endif()
      endwhile()
    endif()
endfunction()




## returns the current stdout of a <process handle>
## this changes until the process is ove
function(process_stdout handle)
    process_handle("${handle}")
    ans(handle)
    map_tryget("${handle}" stdout_file)
    ans(stdout_file)
    fread("${stdout_file}")
    ans(stdout)
return_ref(stdout)
endfunction()





## shorthand to fork a cmake script
function(process_start_script scriptish)
  file_temp_name("{{id}}.cmake")        
  ans(ppath)
  fwrite("${ppath}" "${scriptish}")
  process_start(
    COMMAND
    "${CMAKE_COMMAND}"
    -P
    "${ppath}"
    ${ARGN}
  )
  return_ans()
endfunction()




## returns a <process handle> to a process that runs for n seconds
#todo create shims
function(process_timeout n)
  if(${CMAKE_MAJOR_VERSION} GREATER 2)
    process_start("{command:$CMAKE_COMMAND, args:['-E', 'sleep', $n]}")
    return_ans()
  else()
    if(UNIX)
      process_start("{command:'sleep', args:$n}")
      return_ans()
    endif()
  endif()
endfunction()





  function(string_take_commandline_arg str_ref)
    string_take_whitespace(${str_ref})
    set(regex "(\"([^\"\\\\]|\\\\.)*\")|[^ ]+")
    string_take_regex(${str_ref} "${regex}")
    ans(res)
    if(NOT "${res}_" STREQUAL _)
      set("${str_ref}" "${${str_ref}}" PARENT_SCOPE)
    endif()
    if("${res}" MATCHES "\".*\"")
      string_take_delimited(res "\"")
      ans(res)
    endif()

    return_ref(res)


  endfunction()




## refreshes the fields of the process handle
## returns true if the process is still running false otherwise
## this is the only function which is allowed to change the state of a process handle
function(process_refresh_handle handle)
  process_handle("${handle}")
  ans(handle)


  set(args ${ARGN})

  process_isrunning("${handle}")
  ans(isrunning)





  if(isrunning)
    set(state running)
  else()
    set(state terminated)
  endif()

  # get old state update new state
  map_tryget(${handle} state)
  ans(previous_state)
  map_set(${handle} state "${state}")


  if(NOT "${state}_" STREQUAL "${previous_state}_")
    #message(FORMAT "statechange ({handle.pid}) : {previous_state} -> {state} ")
    if("${state}" STREQUAL "terminated")
      process_return_code("${handle}")
      ans(return_code)
      process_stdout("${handle}")
      ans(stdout)
      process_stderr("${handle}")
      ans(stderr)
      map_capture("${handle}" return_code stdout stderr)
    endif()
  endif()

  return(${isrunning})

endfunction()





# creates a function called ${alias} which wraps the executable specified in ${executable}
# the alias function's varargs will be passed on as command line arguments. 
# if you specify --result the function will return a the execution result object (see execute()) 
# if you specify --return-code the function will return the returncode
# else only the application output will be returned 
# and if the application terminates with an exit code != 0 a fatal error will be raised
function(wrap_executable alias executable)
  set_ans("")
  eval("  
    function(${alias})
      pwd()
      ans(cwd)
      if(NOT IS_DIRECTORY \"\${cwd}\")
        message(FATAL_ERROR \"${alias}: '\${cwd}' is not a directory, try setting it via cd()\")
      endif()
      set(cmd_line_args \${ARGN})
      list_extract_flag(cmd_line_args --result)
      ans(result_flag)
      list_extract_flag(cmd_line_args --return-code)
      ans(return_code_flag)
      set(executable \"${executable}\")
      execute(\"{
        path:$executable,
        args:$cmd_line_args,
        cwd:$cwd
      }\")
      ans(execution_result)
      if(result_flag)
        return(\${execution_result})
      endif()

      map_tryget(\${execution_result} result)
      ans(error)

      if(return_code_flag)
        return_ref(error)
      endif()
      map_tryget(\${execution_result} output)
      ans(stdout)

      if(NOT \"\${error}\" EQUAL 0)

        message(FATAL_ERROR \"failed to execute ${alias} - return code is '\${error}'\\n stderr:\\n \${stdout} \")

        return()
      endif()

      return_ref(stdout)
    endfunction()
    ")
  return()
endfunction()




## returns the current error output
## This can change until the process is finished
function(process_stderr handle)
    process_handle("${handle}")
    ans(handle)
    map_tryget("${handle}" stderr_file)
    ans(stderr_file)
    fread("${stderr_file}")
    ans(stderr)
    return_ref(stderr)
endfunction()






## returns true iff the process identified by <handlish> is running
function(process_isrunning)    
  wrap_platform_specific_function(process_isrunning)    
  process_isrunning(${ARGN})
  return_ans()
endfunction()








  function(command_line_parse_string str)
    uri_parse("${str}")
    ans(uri)

    map_tryget(${uri} rest)
    ans(rest)   


    uri_to_localpath("${uri}")
    ans(command)
    
    set(args)
    while(true)
      string_take_commandline_arg(rest)
      ans(arg)
      string_decode_delimited("${arg}")
      ans(arg)

      list(APPEND args "${arg}")
      if("${arg}_" STREQUAL "_")
        break()
      endif()
    endwhile()

    map_capture_new(command args)
    return_ans()
  endfunction()









## transforms a list of <process handle?!> into a list of <process handle>  
function(process_handles)
  set(handles)
  foreach(arg ${ARGN})
    process_handle("${arg}")
    ans(handle)
    list(APPEND handles ${handle})
  endforeach()
  return_ref(handles)
endfunction()




## prompts the user for input on the console
function(prompt type)

  
  query_type(prompt_input "${type}")
  return_ans()
endfunction()





# calculates and returns the checksum for the specified file
# uses md5 as a default, other algorithms are possible (see string or file for algorithm names)
function(checksum_file file)
  path("${file}")
  ans(path)
  
  set(args ${ARGN})
  list_extract(args checksum_alg)
  if(NOT checksum_alg)
    set(checksum_alg MD5)
  endif()
  file(${checksum_alg} "${file}" checksum)
  return_ref(checksum)
endfunction()







# returns the checksum for the specified object (object graph)
function(checksum_object obj)
  
  json_serialize("${obj}")
  ans(json)
  checksum_string("${json}" ${ARGN})
  return_ans()
endfunction()




# calculates and returns the checksum for the specified directory
# without checking files themselves
# uses md5 as a default, other algorithms are possible (see string or file for algorithm names)
  function(checksum_layout dir)
    path("${dir}")
    ans(dir)

    set(args ${ARGN})
    list_extract(args checksum_alg)

    if(NOT checksum_alg)
      set(checksum_alg MD5)
    endif()

    file(GLOB_RECURSE files RELATIVE "${dir}" "${dir}/**")
    checksum_string("${files}" "${checksum_alg}")
    ans(checksum_dir)

    return_ref(checksum_dir)
  endfunction()




# calculates and returns the checksum for the specified string
# uses md5 as a default, other algorithms are possible (see string or file for algorithm names)
function(checksum_string str)
  set(args ${ARGN})
  list_extract(args checksum_alg)
  if(NOT checksum_alg)
    set(checksum_alg MD5)
  endif()
 # message("string(\"${checksum_alg}\"  \"${str}\" checksum)")
  string("${checksum_alg}"  checksum "${str}" )
  return_ref(checksum)
endfunction()




# calculates and returns the checksum for the specified directory
# including file content
# uses md5 as a default, other algorithms are possible (see string or file for algorithm names)
  function(checksum_dir dir)
    path("${dir}")
    ans(dir)

    set(args ${ARGN})
    list_extract(args checksum_alg)
    if(NOT checksum_alg)
      set(checksum_alg MD5)
    endif()

    file(GLOB_RECURSE files RELATIVE "${dir}" "${dir}/**")
    set(checksums)
    foreach(file ${files})
      checksum_file("${dir}/${file}" "${checksum_alg}")
      ans(file_checksum)
      checksum_string("${file}" "${checksum_alg}")
      ans(string_checksum)
      checksum_string("${file_checksum}${string_checksum}" "${checksum_alg}")
      ans(combined_checksum)
      list(APPEND checksums "${combined_checksum}")
    endforeach()

    checksum_string("${checksums}" "${checksum_alg}")
    ans(checksum_dir)
    return_ref(checksum_dir)
  endfunction()





function(uri uri)
  map_isvalid("${uri}")
  ans(ismap)
  if(ismap)
    return_ref(uri)
  endif()
  uri_parse("${uri}" ${ARGN})
  ans(uri)
  return_ref(uri)
endfunction()









  ## glob(<glob expression...> [--relative] [--recurse]) -> <path...>
  ##
  ## 
 function(glob)
    set(args ${ARGN})
    list_extract_flag(args --relative)
    ans(relative)
    
    list_extract_flag(args --recurse)
    ans(recurse)


    glob_paths(${args})
    ans(globs)

    pwd()
    ans(pwd)
    if(recurse)
      set(glob_command GLOB_RECURSE)
    else()
      set(glob_command GLOB)
    endif()

    if(relative)
      set(relative RELATIVE "${pwd}")
    else()
      set(relative)
    endif()

    set(paths)
    if(globs)
      file(${glob_command} paths ${relative} ${globs})
    endif()
    return_ref(paths)
 endfunction()






  ## glob_expression_parse(<glob ignore path...>) -> {include:<glob path>, exclude:<glob path>}
  ##
  ##
  function(glob_expression_parse)
    set(args ${ARGN})

    map_isvalid("${args}")
    ans(ismap)
    if(ismap)
      return_ref(args)
    endif()

    string(REGEX MATCHALL "![^;]+" exclude "${args}")
    string(REGEX MATCHALL "[^!;]+" exclude "${exclude}")
    string(REGEX MATCHALL "(^|;)[^!;][^;]*" include "${args}")
    string(REGEX MATCHALL "[^;]+" include "${include}")


    map_capture_new(include exclude)
    ans(res)
    return_ref(res)

  endfunction()





## returns a temporary path in the specified directory
## if no directory is given the global temp_dir is used isntead
function(path_temp)
  set(args ${ARGN})

  if("${args}_" STREQUAL "_")
    oocmake_config(temp_dir)
    ans(tmp_dir)
    set(args "${tmp_dir}")
  else()
    path("${args}")
    ans(args)
  endif()

  path_vary("${args}/mktemp")
  ans(path)

  return_ref(path)
endfunction()




# removes the specified paths if -r is passed it will also remove subdirectories
# rm([-r] [<path> ...])
# files names are qualified using pwd() see path()
function(rm)
  set(args ${ARGN})
  list_extract_flag(args -r)
  ans(recurse)
  paths("${args}")
  ans(paths)
  set(cmd)
  if(recurse)
    set(cmd REMOVE_RECURSE)
  else()
    set(cmd REMOVE)
  endif()

  file(${cmd} "${paths}")
  return()
endfunction()






# returns the directory of the specified file
function(parent_dir path)
  path("${path}")
  ans(path)
  get_filename_component(res "${path}" PATH)
  return_ref(res)
endfunction()




  ## cp_content(<source dir> <target dir> <glob ignore expression...>) -> <path...> 
  ## 
  ## copies the content of source dir to target_dir respecting 
  ## the globging expressions if none are given
  ## returns the copied paths if globbing expressiosnw were used
  ## else returns the qualified target_dir
  function(cp_content source_dir target_dir)

    path_qualify(target_dir)
    path_qualify(source_dir)
    set(content_globbing_expression ${ARGN})
    if(NOT content_globbing_expression)
      cp_dir("${source_dir}" "${target_dir}")
      ans(res)
    else()
        pushd("${source_dir}")
            cp_glob("${target_dir}" ${content_globbing_expression})
            ans(res)
        popd()
    endif()
    return_ref(res)
  endfunction()





  ## cp_glob(<target dir> <glob. ..> )-> <path...>
  ##
  ## 
  function(cp_glob target_dir)
    set(args ${ARGN})
    
    list_extract_flag_name(args --recurse)
    ans(recurse)

    path_qualify(target_dir)

    glob_ignore(--relative ${args} ${recurse})
    ans(paths)

    pwd()
    ans(pwd)

    foreach(path ${paths})
      path_component(${path} --parent-dir)
      ans(relative_dir)
      file(COPY "${pwd}/${path}" DESTINATION "${target_dir}/${relative_dir}")
     
    endforeach()
    return_ref(paths)
  endfunction()




## returns the current users home directory on all OSs
## 
function(home_dir)
  shell_get()
  ans(shell)
  if("${shell}" STREQUAL "cmd")
    shell_env_get("HOMEDRIVE")
    ans(dr)
    shell_env_get("HOMEPATH")
    ans(p)
    set(res "${dr}${p}")
    file(TO_CMAKE_PATH "${res}" res)
    #path("${res}")
    #ans(res)
  elseif("${shell}" STREQUAL "bash")
    shell_env_get(HOME)
    ans(res)
  else()
    message(FATAL_ERROR "supported shells: cmd & bash")
  endif() 
  map_set(global home_dir "${res}")
  function(home_dir)
    map_tryget(global home_dir)
    return_ans()
  endfunction()
  return_ref(res)
endfunction()





# replaces the current working directory with
# the top element of the directory stack_pop and
# removes the top element
function(popd)
  stack_pop(__global_push_d_stack)
  ans(pwd)
  cd("${pwd}")
  return_ans()
endfunction()





## prints the specified file to the console
function(fprint path)
  fread("${path}")
  ans(res)
  message("${res}")
  return()
endfunction()







  function(uri_remove_schemes uri)
    uri("${uri}")
    ans(uri)
    map_tryget(${uri} schemes)
    ans(schemes)
    list_remove(schemes ${ARGN})
    map_set(${uri} schemes)
    list_combine("+" ${schemes})
    ans(scheme)
    map_tryget(${uri} scheme)
    return_ref(uri)
  endfunction()




# creates a new directory
function(mkdir path)    
  path("${path}")
  ans(path)
  file(MAKE_DIRECTORY "${path}")
  event_emit(on_mkdir "${path}")
  return_ref(path)
endfunction()






# returns the current working directory
  function(pwd)
    ref_get(__global_cd_current_directory)
    return_ans()
  endfunction()






  function(uri_params_deserialize query)
      
    string(REPLACE "&" "\;" query_assignments "${query}")
    set(query_assignments ${query_assignments})
    string(ASCII 21 c)
    map_new()
    ans(query_data)
    foreach(query_assignment ${query_assignments})
      string(REPLACE "=" "\;"  value "${query_assignment}")
      set(value ${value})
      list_pop_front(value)
      ans(key)
      set(path "${key}")      

      string(REPLACE "[]" "${c}" path "${path}")      
      string(REGEX REPLACE "\\[([^0-9]+)\\]" ".\\1" path "${path}")
      string(REPLACE "${c}" "[]" path "${path}")


      uri_decode("${path}")
      ans(path)
      uri_decode("${value}")
      ans(value)  


      ref_nav_set("${query_data}" "!${path}" "${value}")

    endforeach()
    return_ref(query_data)
  endfunction()





## normalizes the input for the uri
## expects <uri> to have a property called input
## ensures a property called uri is added to <uri> which contains a valid uri string 
function(uri_normalize_input input_uri)
  set(flags ${ARGN})


  # options  
  set(handle_windows_paths true)
  set(default_file_scheme true)
  set(driveletter_separator :)
  set(delimiters "''" "\"\"" "<>")
  set(encode_input 32) # character codes to encode in delimited input
  set(ignore_leading_whitespace true)
  map_get("${input_uri}" input)
  ans(input)

  if(ignore_leading_whitespace)
    string_take_whitespace(input)
  endif()

  set(delimited)
  foreach(delimiter ${delimiters})
    string_take_delimited(input "${delimiter}")
    ans(delimited)
    if(NOT "${delimited}_" STREQUAL "_")
      break()
    endif()
  endforeach()

  set(delimiters "${delimiter}")

    # if string is delimited encode whitespace 
    if(NOT "${delimited}_" STREQUAL "_")
      set(rest "${input}")
      set(input "${delimited}")
      
      if(ignore_leading_whitespace)
        string_take_whitespace(input)
      endif()

      if(encode_input)
        uri_encode("${input}" 32)
        ans(input)
      endif()
    endif()

    

    # the whole uri is delimited by a space or end of string
    string_take_regex(input "${uric}+")
    ans(uri)

    if("${rest}_" STREQUAL "_")
      set(rest "${input}")
    endif()


    set(windows_absolute_path false)
    if(default_file_scheme)
      if(handle_windows_paths)
        # replace backward slash with forward slash
        # for windows paths - non standard behaviour
        string(REPLACE \\ /  uri "${uri}")
      endif()  


      if("_${uri}" MATCHES "^_/" AND NOT "_${uri}" MATCHES "^_//")
        set(uri "file://${uri}")
      endif()

      if("_${uri}" MATCHES "^_[a-zA-Z]:")
        #local windows path no scheme -> scheme is file://
        # <drive letter>: is replaced by /<drive letter>|/
        # also colon after drive letter is normalized to  ${driveletter_separator}
        string(REGEX REPLACE "^_([a-zA-Z]):(.+)" "\\1${driveletter_separator}\\2" uri "_${uri}")
        set(uri "file:///${uri}")
        set(windows_absolute_path true)
      endif()

    endif()
    
    # the rest is not part of input_uri
    map_capture(${input_uri} uri rest delimited_rest delimiters windows_absolute_path)
    return_ref(input_uri)

endfunction()





## copies the contents of source_dir to target_dir
function(cp_dir source_dir target_dir)
  path_qualify(source_dir)
  path_qualify(target_dir)
  cmake(-E copy_directory "${source_dir}" "${target_dir}" --return-code)
  ans(error)
  if(error)
    message(FATAL_ERROR "failed to copy contents of '${source_dir}' to '${target_dir}' ")
  endif()
  return_ref(target_dir)
endfunction()





# returns the specified path component for the passed path
# posibble components are
# --file-name NAME_WE
# --file-name-ext NAME
# --parent-dir PATH
# @todo: create own components 
# e.g. parts dirs extension etc. consider creating an uri type
function(path_component path path_component)
  if("${path_component}" STREQUAL "--parent-dir")
    set(path_component PATH)
  elseif("${path_component}" STREQUAL "--file-name")
    set(path_component NAME_WE)
  elseif("${path_component}" STREQUAL "--file-name-ext")
    set(path_component NAME)
  endif()
  get_filename_component(res "${path}" "${path_component}")
  return_ref(res)
endfunction()








# creates all specified dirs
function(mkdirs)
  set(res)
  foreach(path ${ARGN})
    mkdir("${path}")
    ans(p)
    list(APPEND res "${p}")    
  endforeach()
  return_ref(res)
endfunction()







## parses an uri
## input can be any path or uri
## whitespaces in segments are allowed if string is delimited by double or single quotes(non standard behaviour)
##{
#  scheme,
#  net_root: # is // if the uri is a net uri
#  authority: # is the authority part if uri has a net_root
#  abs_root: # is / if the uri is a absolute path
#  segments: # an array of uri segments (folder)
#  file: # the last segment 
#  file_name: # the last segment without extension 
#  extension: # extension of file 
#  rest: # the ret of the input string which is not part of the uri
#  query: # the query part of the uri 
#  fragment # fragment part of uri
# }
##
##
##
function(uri_parse str)
  set(flags ${ARGN})

  list_extract_labelled_value(flags --into-existing)
  ans(res)

  list_extract_flag(flags --notnull)
  ans(notnull)
  if(notnull)
    set(notnull --notnull)
  else()
    set(notnull)
  endif()


  regex_uri()



  # set input data for uri
  if(NOT res)
    map_new()
    ans(res)
  endif()


  map_set(${res} input "${str}")


  ## normalize input of uri
  uri_normalize_input("${res}" ${flags})
  map_get("${res}" uri)
  ans(str)

  # scheme
  string_take_regex(str "${scheme_regex}:")
  ans(scheme)

  if(NOT "${scheme}_"  STREQUAL _)
    string_slice("${scheme}" 0 -2)
    ans(scheme)
  endif()

  # scheme specic part is rest of uri
  set(scheme_specific_part "${str}")


  # net_path
  string_take_regex(str "${net_root_regex}")
  ans(net_path)

  # authority
  set(authority)
  if(net_path)
    string_take_regex(str "${authority_regex}")
    ans(authority)
  endif()

  string_take_regex(str "${path_char_regex}+")
  ans(path)

  string_take_regex(str "${query_regex}")
  ans(query)
  if(query)
    string_slice("${query}" 1 -1)
    ans(query)
  endif()



  if(net_path)
    set(net_path "${authority}${path}")
  endif()

  string_take_regex(str "${fragment_regex}")
  ans(fragment)
  if(fragment)
    string_slice("${fragment}" 1 -1)
    ans(fragment)
  endif()


  map_capture(${res}
    
    scheme 
    scheme_specific_part
    net_path
    authority 
    path      
    query 
    fragment 

    ${notnull}
  )



  # extended parse
  uri_parse_scheme(${res})
  uri_parse_authority(${res})
  uri_parse_path(${res})
  uri_parse_file(${res})
  uri_parse_query(${res})      



  return_ref(res)

endfunction()




# reads the file specified and returns its content
function(fread path)
  path("${path}")
  ans(path)
  file(READ "${path}" res)
  return_ref(res)
endfunction()





## qualifies the specified variable as a path and sets it accordingly
macro(path_qualify __path_ref)
  path("${${__path_ref}}")
  ans(${__path_ref})
endmacro()





## formats an <uri~> to a localpath 
function(uri_to_localpath uri)
  uri("${uri}")
  ans(uri)

  map_tryget("${uri}" normalized_segments)
  ans(segments)

  map_tryget(${uri} leading_slash)
  ans(rooted)

  map_tryget(${uri} trailing_slash)
  ans(trailing_slash)

  map_tryget(${uri} windows_absolute_path)
  ans(windows_absolute_path)

  string_combine("/" ${segments})
  ans(path)

  if(WIN32 AND "${path}" MATCHES "^[a-zA-Z]:")
    # do nothing
  elseif(rooted AND NOT windows_absolute_path)
    set(path "/${path}")
  endif()
  set(path "${path}${trailing_slash}")
  return_ref(path)
endfunction()







  ## expects last_segment property to exist
  ## ensures file_name, file, extension exists
  function(uri_parse_file uri)
    map_get("${uri}" last_segment)
    ans(file)

    if("_${file}" MATCHES "\\.") # file contains an extension
      string(REGEX MATCH "[^\\.]*$" extension "${file}")
      string(LENGTH "${extension}" extension_length)

      if(extension_length)
        math(EXPR extension_length "0 - ${extension_length}  - 2")
        string_slice("${file}" 0 ${extension_length})
        ans(file_name)
      endif()
    else()
      set(file_name "${file}")
      set(extension "")
    endif()
    map_capture(${uri} file extension file_name)
  endfunction()




# creates a file or updates the file access time
# *by appending an empty string
function(touch path)

  #if("${CMAKE_MAJOR_VERSION}" LESS 3)
    function(touch path)

      path("${path}")
      ans(path)

      set(args ${ARGN})
      list_extract_flag(args --nocreate)
      ans(nocreate)

      if(NOT EXISTS "${path}" AND nocreate)
        return_ref(path)
      elseif(NOT EXISTS "${path}")
        file(WRITE "${path}" "")        
      else()
        file(APPEND "${path}" "")
      endif()


      return_ref(path)

    endfunction()
  #else()
  #  function(touch path)
  #    path("${path}")
  #    ans(path)
#
#  #    set(args ${ARGN})
#  #    list_extract_flag(args --nocreate)
#  #    ans(nocreate)
#
#
#
#  #    set(cmd touch)
#  #    if(nocreate)
#  #      set(cmd touch_nocreate)
#
#  #    endif()
#
#  #    cmake(-E ${cmd} "${path}" --result)
#  #    ans(res)
#  #    json_print(${res})
#  #    map_tryget(${res} result)
#  #    ans(erro)
#  #    if(erro)
#  #      message(FATAL_ERROR "faild")
#  #    endif()
#  #    return_ref(path)
#  #  endfunction()
  #endif()
  touch("${path}")
  return_ans()
endfunction()






function(uri_parse_scheme uri)
  map_tryget(${uri} scheme)
  ans(scheme)

  string(REPLACE "+" "\;" schemes "${scheme}")
  map_set(${uri} schemes ${schemes})

endfunction()




# pushes the specfied directory (or .) onto the 
# directory stack
function(pushd)
  pwd()
  ans(pwd)
  stack_push(__global_push_d_stack "${pwd}")
  if(ARGN)
    cd(${ARGN})
    return_ans()
  endif()
  return_ref(pwd)
endfunction()






  ## glob_ignore(<glob ignore expression...> [--relative] [--recurse]) -> <path...>
  ##
  ## 
  function(glob_ignore)
    set(args ${ARGN})
    list_extract_flag_name(args --relative)
    ans(relative)
    list_extract_flag_name(args --recurse)
    ans(recurse)


    glob_expression_parse(${args})
    ans(glob_expression)

    map_import_properties(${glob_expression} include exclude)

    glob(${relative} ${include} ${recurse})
    ans(included_paths)

    glob(${relative} ${exclude} ${recurse})
    ans(excluded_paths)
    if(excluded_paths)
      list(REMOVE_ITEM included_paths ${excluded_paths})
    endif()
    return_ref(included_paths)
  endfunction()
  





# retuns the extension of the specified file
function(file_extension path)
  path("${path}")
  ans(path)
  get_filename_component(res "${path}" EXT)
  return_ref(res)  
endfunction()





  ## tries to interpret the uri as a local path and replaces it 
  ## with a normalized local path (ie file:// ...)
  ## returns a new uri
  function(uri_qualify_local_path uri)
    uri("${uri}")
    ans(uri)

    map_tryget(${uri} input)
    ans(uri_string)

    map_tryget(${uri} normalized_host)
    ans(normalized_host)

    map_tryget("${uri}" scheme)
    ans(scheme)


    ## check if path path is going to be local
    eval_truth(
       "${scheme}_" MATCHES "(^_$)|(^file_$)" # scheme is file
       AND normalized_host STREQUAL "localhost" # and host is localhost 
       AND NOT "${uri_string}" MATCHES "^[^/]+:" # and input uri is not scp like ssh syntax
     ) 
    ans(is_local)

    ## special handling of local path
    if(is_local)
      ## use the locally qualfied full path
      map_get("${uri}" path)
      ans(local_path)
      path_qualify(local_path)
      map_tryget(${uri} params)
      ans(params)
      uri("${local_path}")
      ans(uri)
      map_set("${uri}" params "${params}")
    endif()
    return_ref(uri)
  endfunction()




## path_qualify_from(<base_dir:<qualified path>> <~path>) -> <qualified path>
##
## qualfies a path using the specified base_dir
##
## if path is absolute (starts with / or under windows with <drive letter>:/) 
## it is returned as is
##
## if path starts with a '~' (tilde) the path is 
## qualfied by prepending the current home directory
##
## is neither absolute nor starts with ~
## the path is relative and it is qualified 
## by prepending the specified <base dir>
function(path_qualify_from base_dir path)
  string(REPLACE \\ / path "${path}")
  get_filename_component(realpath "${path}" REALPATH)
  
  ## windows absolute path
  if(WIN32 AND "_${path}" MATCHES "^_[a-zA-Z]:\\/")
    return_ref(realpath)
  endif()
   
   ## posix absolute path
  if("_${path}" MATCHES "^_\\/")
    return_ref(realpath)
  endif()


  ## home path
  if("_${path}" MATCHES "^_~\\/?(.*)")
    home_dir()
    ans(base_dir)
    set(path "${CMAKE_MATCH_1}")
  endif()

  set(path "${base_dir}/${path}")

  ## relative path
  get_filename_component(realpath "${path}" REALPATH)
  
  return_ref(realpath)
endfunction()








  ## downloadsa the specified url and stores it in target file
  ## if specified
  ## --refresh causes the cache to be updated
  ## --readonly allows optimization if the result is not modified
  function(download_cached uri)
    set(args ${ARGN})
    list_extract_flag(args --refresh)
    ans(refresh)
    list_extract_flag(args --readonly)
    ans(readonly)
    
    oocmake_config(temp_dir)
    ans(temp_dir)

    string(MD5 cache_key "${uri}")
    set(cached_path "${temp_dir}/download_cache/${cache_key}")
   
    if(EXISTS "${cached_path}" AND NOT refresh)
      if(readonly)
        file_glob("${cached_path}" "**")
        ans(file_path)
        return_ref(file_path)
      else()
        message(FATAL_ERROR "not supported")
      endif()
    endif()

    mkdir("${cached_path}")
    download("${uri}" "${cached_path}" ${args})
    ans(res)
    if(NOT res)
      rm("${cached_path}")
    endif()
    return_ref(res)
  endfunction()





# copies the specified path to the specified target
# if last argument is a existing directory all previous files will be copied there
# else only two arguments are allow source and target
# cp(<sourcefile> <targetfile>)
# cp([<sourcefile> ...] <existing targetdir>)
function(cp)
  set(args ${ARGN})
  list_pop_back(args)
  ans(target)

  list_length(args)
  ans(len)
  path("${target}")
  ans(target)
  # single move

  if(NOT IS_DIRECTORY "${target}" )
    if(NOT "${len}" EQUAL "1")
      message(FATAL_ERROR "wrong usage for cp() exactly one source file needs to be specified")
    endif() 
    path("${args}")
    ans(source)
    # this just has to be terribly slow... 
    # i am missing a direct
    cmake(-E "copy" "${source}" "${target}" --return-code)
    ans(ret)
    if(NOT "${ret}" STREQUAL 0)
      message("failed to copy ${source} to ${target}")
    endif()
   return()
  endif()


  paths(${args})
  ans(paths)
  file(COPY ${paths} DESTINATION "${target}") 
  

  return()
endfunction()







  function(uri_parse_path uri)
    map_get("${uri}" path)
    ans(path)    

    set(segments)
    set(encoded_segments)
    set(last_segment)
    string_take_regex(path "${segment_separator_char}")
    ans(slash)
    set(leading_slash ${slash})

    while(true) 
      string_take_regex(path "${segment_char}+" )
      ans(segment)

  


      if("${segment}_" STREQUAL "_")
        break()
      endif()

      string_take_regex(path "${segment_separator_char}")
      ans(slash)


      list(APPEND encoded_segments "${segment}")

      uri_decode("${segment}")
      ans(segment)
      list(APPEND segments "${segment}")
      set(last_segment "${segment}")
    endwhile()


    set(trailing_slash "${slash}")


    set(normalized_segments)
    set(current_segments ${segments})   

    while(true)
      list_pop_front(current_segments)
      ans(segment)

      if("${segment}_" STREQUAL "_")
        break()
      elseif("${segment}" STREQUAL ".")

      elseif("${segment}" STREQUAL "..")
        list(LENGTH normalized_segments len)

        list_pop_back(normalized_segments)
        ans(last)
        if("${last}" STREQUAL ".." )
          list(APPEND normalized_segments .. ..)
        elseif("${last}_" STREQUAL "_" )
          list(APPEND normalized_segments ..)
        endif()
      else()
        list(APPEND normalized_segments "${segment}")
      endif()
    endwhile()

    if(("${segments}_" STREQUAL "_") AND leading_slash)
      set(trailing_slash "")
    endif()


    map_capture(${uri} segments encoded_segments last_segment trailing_slash leading_slash normalized_segments)
    return()
  endfunction()




# reads the file specified and returns its content
function(flines path)
  path("${path}")
  ans(path)
  file(STRINGS "${path}" res)
  return_ref(res)
endfunction()








  ## this is a hard hack to read unicode 16 files
  ##  it reads the file by lines and concatenates the result which removes all linebreaks  
  ## please don't use this :)
  function(fread_unicode16 path)
    path("${path}")
    ans(path)
    file(STRINGS "${path}" lines)  
    string(CONCAT res ${lines})
    return_ref(res)
  endfunction()





function(uri_parse_authority uri)
  map_get(${uri} authority)
  ans(authority)

  map_get(${uri} net_path)
  ans(net_path)

  ## set authoirty to localhost if no other authority is specified but it is a net_path (starts wth //)
  if("_authority" STREQUAL "_" AND NOT "${net_path}_" STREQUAL "_")
    set(authority localhost)
  endif()

  dns_parse("${authority}")
  ans(dns)

  map_iterator(${dns})
  ans(it)
  while(true)
    map_iterator_break(it)
    if(NOT "${it.key}" STREQUAL "rest")
      map_set(${uri} ${it.key} ${it.value})
    endif()
  endwhile()

  return()

endfunction()





# returns the name of the file without the directory
# if -we is specified the extensions is dropped
function(file_name path)
  set(args ${ARGN})
  list_extract_flag(args -we)
  ans(without_extension)
  if(without_extension)
    set(cmd NAME_WE)
  else()
    set(cmd NAME)
  endif() 
  path("${path}")
  ans(path)
  get_filename_component(res "${path}" ${cmd})
  return_ref(res)
endfunction()




# writs argn to the speicified file creating it if it does not exist and 
# overwriting it if it does.
function(fwrite path)
  path("${path}")
  ans(path)
  file(WRITE "${path}" "${ARGN}")
  event_emit(on_fwrite "${path}")
  return_ref(path)
endfunction()




## download(uri [target] [--progress])
## downloads the specified uri to specified target path
## if target path is an existing directory the files original filename is kept
## else target is treated as a file path and download stores the file there
## if --progress is specified then the download progress is shown
## returns the path of the successfully downloaded file or null
function(download uri)
  set(args ${ARGN})

  set(uri_string "${uri}")
  uri("${uri}")
  ans(uri)


  list_extract_flag(args --progress)
  ans(show_progress)
  if(show_progress)
    set(show_progress SHOW_PROGRESS)
  else()
    set(show_progress)
  endif()

  list_pop_front(args)
  ans(target_path)
  path_qualify(target_path)

  map_tryget("${uri}" file)
  ans(filename)

  if(IS_DIRECTORY "${target_path}")
    set(target_path "${target_path}/${filename}")    
  endif()

  file(DOWNLOAD 
    "${uri_string}" "${target_path}" 
    STATUS status 
   # LOG log
    ${show_progress}
    TLS_VERIFY OFF 
    ${args})


  list_extract(status code message)
  if(NOT "${code}" STREQUAL 0)    
    #message(WARNING "${message}")
    rm("${target_path}")
    return()
  endif()

  return_ref(target_path)
endfunction()





  function(uri_format uri)
    set(args ${ARGN})

    list_extract_flag(args --no-query)
    ans(no_query)

    list_extract_flag(args --no-scheme)
    ans(no_scheme)

    list_extract_labelled_value(args --remove-scheme)
    ans(remove_scheme)



    obj("${args}")
    ans(payload)


    uri("${uri}")
    ans(uri)
    map_tryget("${uri}" params)
    ans(params)

    if(payload)

      map_merge( "${params}" "${payload}")
      ans(params)
    endif()

    set(query)
    if(NOT no_query)
      uri_params_serialize("${params}")
      ans(query)
      if(query)
        set(query "?${query}")
      endif()
    endif()

    if(NOT no_scheme)

      if(NOT remove_scheme STREQUAL "")
        map_tryget("${uri}" schemes)
        ans(schemes)

        string(REPLACE "+" ";" remove_scheme "${remove_scheme}")

        list_remove(schemes ${remove_scheme})
        string_combine("+" ${schemes})
        ans(scheme)
      else()
        map_tryget("${uri}" scheme)
        ans(scheme)
      endif()

      if(NOT "${scheme}_" STREQUAL "_")
        set(scheme "${scheme}:")
      endif()
    endif()

    map_tryget("${uri}" net_path)
    ans(net_path)

    if("${net_path}_" STREQUAL "_")
      map_tryget(${uri} path)
      ans(path)
      set(uri_string "${scheme}${path}${query}")
    else()
      set(uri_string "${scheme}//${net_path}${query}")
    endif()
    return_ref(uri_string)

  endfunction()




  ## fwrite_data(<path> ([--mimetype <mime type>]|[--json]|[--qm]) <~structured data?>) -> <structured data>
  ##
  ## writes the specified data into the specified target file (overwriting it if it exists)
  ##
  ## fails if no format could be chosen
  ##
  ## format:  if you do not specify a format by passing a mime-type
  ##          or type flag the mime-type is chosen by analysing the 
  ##          file extension - e.g. *.qm files serialize to quickmap
  ##          *.json files serialize to json
  ##
  function(fwrite_data target_file)
    set(args ${ARGN})

    ## choose mime type
    list_extract_labelled_value(args --mime-type)
    ans(mime_types)

    list_extract_flag(args --json)
    ans(json)

    list_extract_flag(args --qm)
    ans(quickmap)

    if(json)
      set(mime_types application/json)
    endif()

    if(quickmap)
      set(mime_types application/x-quickmap)
    endif()


    if(NOT mime_types)
      mime_type_from_filename("${target_file}")
      ans(mime_types)
      if(NOT mime_types)
        set(mime_types "application/json")
      endif()
    endif()

    ## parse data
    data(${args})
    ans(data)


    ## serialize data
    if("${mime_types}" MATCHES "application/json")
      json_serialize("${data}")
      ans(serialized)
    elseif("${mime_types}" MATCHES "application/x-quickmap")
      qm_serialize("${data}")
      ans(serialized)
    else()
      message(FATAL_ERROR "serialization to '${mime_types}' is not supported")
    endif()

    ## write and return data
    fwrite("${target_file}" "${serialized}")
    return_ref(data)
  endfunction()





# returns a list of files
# todo: http://ss64.com/bash/ls.html
function(ls)
  path("${ARGN}")
  ans(path)

  if(IS_DIRECTORY "${path}")
    set(path "${path}/*")
  endif()

  file(GLOB files "${path}")
  return_ref(files)
endfunction()





# creates a temporary directory 
# you can specify an optional parent directory in which it should be created
# usage: mktemp([where])-> <absoute path>
function(mktemp)
  path_temp(${ARGN})
  ans(path)
  mkdir("${path}")
  return_ref(path)
endfunction()





# moves the specified path to the specified target
# if last argument is a existing directory all previous files will be moved there
# else only two arguments are allow source and target
# mv(<sourcefile> <targetfile>)
# mv([<sourcefile> ...] <existing targetdir>)
function(mv)
  set(args ${ARGN})
  list_pop_back(args)
  ans(target)

  list_length(args)
  ans(len)
  path("${target}")
  ans(target)
  # single move
  if(NOT IS_DIRECTORY "${target}" )
    if(NOT "${len}" EQUAL "1")
      message(FATAL_ERROR "wrong usage for mv() exactly one source file needs to be specified")
    endif()
    path("${args}")
    ans(source)
    file(RENAME "${source}" "${target}")
    return()
  endif()

  foreach(source ${args})
    file_name("${source}")
    ans(fn)
    mv("${source}" "${target}/${fn}")
  endforeach()

  return()
endfunction()






## ensures that the directory specified exists 
## the directory is qualified with path()
function(directory_ensure_exists path)
  path("${path}")
  ans(path)
  if(EXISTS "${path}")
    if(IS_DIRECTORY "${path}")
      return("${path}")
    endif()
    return()
  endif()
  mkdir("${path}")
  return_ans()
endfunction()





## returns the timestamp for the specified path
function(file_timestamp path)
  path("${path}")
  ans(path)

  if(NOT EXISTS "${path}")
    return()
  endif()

  file(TIMESTAMP "${path}" res)


  return_ref(res)
endfunction()





#  varies the specified path until it does not exist
# this is done  by appending a random string at the end of the path
# todo: allow something like map_format or a callback to vary a path
function(path_vary path)
  path("${path}")
  ans(base_path)

  set(path "${base_path}")
  while(true)
    
    if(NOT EXISTS "${path}")
      return("${path}")
    endif()

    string(RANDOM rnd)
    set(path "${base_path}${rnd}")
  endwhile()
endfunction()





## qualifies the specified path with the home directory
function(home_path path)
  home_dir()
  ans(home)
  set(path "${home}/${path}")
  return_ref(path)
endfunction()





# writes a file_map to the pwd.
# empty directories are not created
# fm is parsed according to obj()
function(file_map_write fm)


  # define callbacks for building result
  function(fmw_dir_begin)
    map_tryget(${context} current_key)
    ans(key)
    if("${map_length}" EQUAL 0)
      return()
    endif()
    if(key)
      pushd("${key}" --create)
    else()
      pushd()
    endif()
  endfunction()
  function(fmw_dir_end)
    if(NOT "${map_length}" EQUAL 0)    
      popd()
    endif()
  endfunction()
  function(fmw_path_change)
    map_set(${context} current_key "${map_element_key}")
  endfunction()

  function(fmw_file)
    map_get(${context} current_key) 
    ans(key)
    fwrite("${key}" "${node}")
  endfunction()

   map()
    kv(value              fmw_file)
    kv(map_begin          fmw_dir_begin)
    kv(map_end            fmw_dir_end)
    kv(list_begin         fmw_file)
    kv(map_element_begin  fmw_path_change)
  end()
  ans(file_map_write_cbs)
  function_import_table(${file_map_write_cbs} file_map_write_callback)

  # function definition
  function(file_map_write fm)            
    obj("${fm}")
    ans(fm)

    map_new()
    ans(context)
    dfs_callback(file_map_write_callback ${fm} ${ARGN})
    map_tryget(${context} files)
    return_ans()  
  endfunction()
  #delegate
  file_map_write(${fm} ${ARGN})
  return_ans()
endfunction()

function(file_map_read)
  path("${ARGN}")
  ans(path)
  message("path ${path}")
  
  file(GLOB_RECURSE paths RELATIVE "${path}" ${path}/**)
  #file_glob("${path}" **/** --relative)
  #ans(paths)

  message("paths ${paths}")

 # paths_to_map(${paths})


  return_ans()

endfunction()




# returns the fully qualified path name for path
# if path is a fully qualified name it returns path
# else path is interpreted as the relative path 
function(path path)
  pwd()
  ans(pwd)
  path_qualify_from("${pwd}" "${path}")
  return_ans()
endfunction()







  function(uri_params_serialize )
    function(uri_params_serialize_value)

      set(path ${path})
      list_pop_front(path)
      ans(first)


      set(res "${first}")
      foreach(part ${path})
        uri_encode("${part}")
        ans(part)
        set(res "${res}[${part}]")
      endforeach()

      uri_encode("${node}")
      ans(node)
      set(res "${res}=${node}")
      map_append(${context} assignments ${res})
    endfunction()
   map()
    kv(value uri_params_serialize_value)
   end()
  ans(callbacks)
  function_import_table(${callbacks} uri_params_serialize_callback)

  # function definition
  function(uri_params_serialize obj )
    obj("${obj}")
    ans(obj)  
    map_new()
    ans(context)
    dfs_callback(uri_params_serialize_callback ${obj})
    map_tryget(${context} assignments)
    ans(assignments)
    string_combine("&" ${assignments})
    return_ans()  
  endfunction()
  #delegate
  uri_params_serialize(${ARGN})
  return_ans()
  endfunction()





  ## glob_paths(<unqualified glob path...>) -> <qualified glob path...>
  ##
  ## 
 function(glob_paths)
  set(result)
  foreach(path ${ARGN})
    glob_path(${path})
    ans(res)
    list(APPEND result ${res})
  endforeach()
  return_ref(result)
 endfunction()






  ## glob_paths(<unqualified glob path>) -> <qualified glob path.>
  ##
  ## 
  function(glob_path glob)
    string_take_regex(glob "[^\\*\\[{]+")
    ans(path)
    path_qualify(path)

    if(glob)
      set(path "${path}/${glob}")
    endif()
    return_ref(path)
 endfunction()





## parses the query field of uri and sets  the uri.params field to the parsed data
function(uri_parse_query uri)
  map_tryget(${uri} query)
  ans(query)
  uri_params_deserialize("${query}")
  ans(params)
  map_set(${uri} params ${params})
  return()

endfunction()




# returns all directories currently on directory stack
# also see pushd popd
function(dirs)
  stack_enumerate(__global_push_d_stack)
  ans(res)
  return_ref(res)
endfunction()





function(parent_dir_name)
  path("${ARGN}")
  ans(path)
  path_component("${path}" --file-name-ext)
  return_ans()
endfunction()






  function(dns_parse input)
    regex_uri()

    string_take_regex_replace(input "${dns_user_info_regex}" "\\1")
    ans(user_info)
    
    set(host_port "${input}")



    string_take_regex_replace(input "${dns_host_regex}" "\\1")
    ans(host)


    string_take_regex(input "${dns_port_regex}")
    ans(port)


    if(port AND NOT "${port}" LESS 65536)
      return()
    endif()
    set(rest ${input})

    set(input "${host}")
    string_take_regex(input "${ipv4_regex}")
    ans(ip)

    set(top_label)
    set(labels)
    if(NOT ip)
      while(true)
        string_take_regex(input "${dns_domain_label_regex}")
        ans(label)
        if("${label}_" STREQUAL "_")
          break()

        endif()
        set(top_label "${label}")
        list(APPEND labels "${label}")
        string_take_regex(input "${dns_domain_label_separator}")
        ans(separator)
        if(NOT separator)
          break()
        endif()

      endwhile()


    endif()

    list(LENGTH labels len)
    set(domain)
    if("${len}" GREATER 1)
      list_slice(labels -3 -1)
      ans(domain)
      string_combine("." ${domain} )
      ans(domain)
    else()
      set(domain "${top_label}")
    endif()

    string_split_at_first(user_name password "${user_info}" ":")


    set(normalized_host "${host}")
    if("${normalized_host}_" STREQUAL "_" )
      set(normalized_host localhost)
    endif()

    map_capture_new(
      user_info
      user_name
      password
      host_port
      host
      normalized_host
      labels
      top_label
      domain
      ip
      port
      rest
      )
    return_ans()
  endfunction()




function(fappend path)
  path("${path}")
  ans(path)
  file(APPEND "${path}" ${ARGN})
  return()
endfunction()




# changes the current directory 
function(cd)
  set(args ${ARGN})
  list_extract_flag(args --create)
  ans(create)
  path("${args}")
  ans(path)
 # message("cd ${path}")
  if(NOT IS_DIRECTORY "${path}")
    if(NOT create)
      message(FATAL_ERROR "directory '${path}' does not exist")
      return()
    endif()
    mkdir("${path}")
  endif()
  ref_set(__global_cd_current_directory "${path}")
  return_ref(path)
endfunction()





# qualify multiple paths (argn)
function(paths)
  set(res)
  foreach(path ${ARGN})
    path("${path}")
    ans(path)
    list(APPEND res ${path})
  endforeach()
  return_ref(res)
endfunction()





  function(ref_prop_set ref prop)
    map_get_special("${ref}" object)
    ans(isobject)
    if(isobject)
      obj_set("${ref}" "${prop}" ${ARGN})
    else()
      map_set("${ref}" "${prop}" ${ARGN})
    endif()
  endfunction()







  function(ref_nav_create_path expression)
    navigation_expression_parse("${expression}")
    ans(expression)
    set(current_value ${ARGN})
    while(true)
      list(LENGTH expression continue)
      if(NOT continue)
        break()
      endif()

      list_pop_back(expression)
      ans(current_expression)
      if(NOT "${current_expression}" STREQUAL "[]")
        if("${current_expression}" MATCHES "^[<>].*[<>]$")
          message(FATAL_ERROR "invalid range: ${current_expression}")
        endif()
        map_new()
        ans(next_value)
        map_set("${next_value}" "${current_expression}" "${current_value}")
        set(current_value "${next_value}")
      endif()
    endwhile()
    return_ref(current_value)
  endfunction()








## parses and registers a type or returns an existing one by type_name

function(type_def)
  function(type_def)
    data("${ARGN}")
    ans(type)

    if("${type}_" STREQUAL "_")
      set(type any)
    endif()


    list(LENGTH type length)
    if(length GREATER 1)
      map_new()
      ans(t)
      map_set(${t} properties ${type})
      set(type ${t})
    endif()


    map_isvalid("${type}")
    ans(ismap)
    if(ismap)
      map_tryget(${type} type_name)
      ans(type_name)
      if("${type_name}_" STREQUAL "_")
        string(RANDOM type_name)
        map_set("${type}" "anonymous" true)
        #map_set(${type} "type_name" "${type_name}")
      else()
        map_set("${type}" "anonymous" false)
      endif()
    
      map_tryget(data_type_map "${type_name}")
      ans(registered_type)
      if(NOT registered_type)
        map_set(data_type_map "${type_name}" "${type}")
      endif()
      
      map_tryget("${type}" properties)
      ans(props)
      map_isvalid("${props}")
      ans(ismap)
      if(ismap)
        map_iterator("${props}")
        ans(it)
        set(props)
        while(true)
          map_iterator_break(it)
          list(APPEND props "${it.key}:${it.value}")

        endwhile()
        map_set(${type} properties "${props}")
      endif()

      return_ref(type)



    endif()


    map_tryget(data_type_map "${type}")
    ans(res)
    if(res)
      return_ref(res)
    endif()


    map_new()
    ans(res)

    map_set(${res} type_name "${type}")
    map_set(data_type_map "${type}" "${res}")
    return_ref(res)
  endfunction()

  type_def("{
    type_name:'string'
    }")


  type_def("{
    type_name:'int',
    regex:'[0-9]+'
  }")

  type_def("{
    type_name:'any'
  }")


  type_def("{
    type_name:'bool',
    regex:'true|false'
  }")

  
  type_def(${ARGN})
  return_ans()
endfunction()





  function(ref_pop_front ref)
    ref_get(${ref})
    ans(value)
    list_pop_front(value)
    ans(res)
    ref_set(${ref} ${value})
    return_ref(res)
  endfunction()




function(ref_isvalid ref)
  list(LENGTH ref len)
  if(NOT ${len} EQUAL 1)
    return(false)
  endif()
	string(REGEX MATCH "^:" res "${ref}" )
	if(res)
		return(true)
	endif()
	return(false)
endfunction()




function(ref_delete ref)
	set_property(GLOBAL PROPERTY "${ref}")
endfunction()






  function(ref_peek_back ref)
    ref_get(${ref})
    ans(value)
    list_peek_back(value ${ARGN})
    ans(res)
    return_ref(res)
  endfunction()




function(ref_setnew)
	ref_new()
  ans(res)
	ref_set(${res} "${ARGN}")
  return(${res})
endfunction()




function(ref_gettype ref)
	ref_isvalid(${ref})
  ans(is_ref)
	if(NOT is_ref)
		return()
	endif()
	ref_get("${ref}.__type__")
  ans(type)
	return_ref(type)
endfunction()





  function(ref_peek_front ref)
    ref_get(${ref})
    ans(value)
    list_peek_front(value ${ARGN})
    ans(res)
    return_ref(res)
  endfunction()




function(ref_istype ref expectedType)
	ref_isvalid(${ref})
	ans(isref)

	if(NOT isref)
		return(false)
	endif()
	
	ref_gettype(${ref})
  ans(type)
	if(NOT "${type}" STREQUAL "${expectedType}" )
		return(false)
	endif()
	return(true)
endfunction()




function(ref_append ref)
	set_property( GLOBAL APPEND PROPERTY "${ref}" "${ARGN}")
endfunction()





  function(ref_push_front ref)
    ref_get(${ref})
    ans(value)
    list_push_front(value ${ARGN})
    ans(res)
    ref_set(${ref} ${value})
    return_ref(res)
  endfunction()




function(ref_print ref)
  ref_get("${ref}")
  _message("${ref}")
endfunction()




function(ref_new)
	ref_set(__global_ref_count 0)
	
	function(ref_new)
		ref_get(__global_ref_count )
		ans(index)
		math(EXPR index "${index} + 1")
		ref_set(__global_ref_count "${index}")
		if(ARGN)
		#	set(type "${ARGV0}")
			ref_set(":${index}.__type__" "${ARGV0}")
		endif()
		return(":${index}")
	endfunction()

	ref_new(${ARGN})
	return_ans()
endfunction()

## optimized version
function(ref_new)
	set_property(GLOBAL PROPERTY __global_ref_count 0 )
	function(ref_new)
		get_property(index GLOBAL PROPERTY __global_ref_count)
		math(EXPR index "${index} + 1")
		set_property(GLOBAL PROPERTY __global_ref_count ${index} )
		if(ARGN)
			set_property(GLOBAL PROPERTY ":${index}.__type__" "${ARGV0}")
		endif()
		set(__ans ":${index}" PARENT_SCOPE)
	endfunction()

	ref_new(${ARGN})
	return_ans()
endfunction()




function(ref_prepend ref)
  get_property(value GLOBAL PROPERTY "${ref}")
  set_property( GLOBAL PROPERTY "${ref}" "${ARGN}" "${value}")
  return()
endfunction()





  function(ref_push_back ref)
    ref_get(${ref})
    ans(value)
    list_push_back(value "${ARGN}")
    ans(res)
    ref_set(${ref} ${value})
    return_ref(res)
  endfunction()





  function(ref_pop_back ref)
    ref_get(${ref})
    ans(value)
    list_pop_back(value)
    ans(res)
    ref_set(${ref} ${value})
    return_ref(res)
  endfunction()




function(ref_get ref )
	get_property(ref_value GLOBAL PROPERTY "${ref}")
  return_ref(ref_value)
endfunction()

# optimized version
macro(ref_get ref)
  get_property(__ans GLOBAL PROPERTY "${ref}")
endmacro()




function(ref_set ref)
	set_property(GLOBAL PROPERTY "${ref}" "${ARGN}")
endfunction()





function(ref_append_string ref str)
  ref_get(${ref} )
  ans(res)
  set(res "${res}${str}")
  ref_set(${ref} "${res}")
  return_ref(str)
endfunction()





  function(ref_nav_get current_value)
    set(expression ${ARGN})
    string_take(expression "&")
    ans(return_lvalue)

    navigation_expression_parse("${expression}")
    ans(expression)

    set(current_ref)
    set(current_property)
    set(current_ranges)
    foreach(current_expression ${expression})
      if("${current_expression}" MATCHES "^[<>].*[<>]$")
        list_range_try_get(current_value "${current_expression}")
        ans(current_value)
        list(APPEND current_ranges ${current_expression})
      else()
        map_isvalid("${current_value}")
        ans(is_ref)

        if(NOT is_ref)
          break()
        endif()
        set(current_ref "${current_value}")
        set(current_property "${current_expression}")
        set(current_ranges)

        ref_prop_get("${current_value}" "${current_expression}")
        ans(current_value)
      endif()
    endforeach()
    if(return_lvalue)
      map_capture_new(ref:current_ref property:current_property range:current_ranges value:current_value --reassign)
      return_ans()
    endif()
    return_ref(current_value)

  endfunction()







  function(line line)
    listing_append("${__listing_current}" "${line}")
  endfunction()






  function(listing_append listing line)
    string_combine(" " ${ARGN})
    ans(rest)
    string_semicolon_encode("${line}${rest}")
    ans(line)
    ref_append("${listing}" "${line}")
    return()
  endfunction()





  function(listing_include listing)
    listing_compile("${listing}")
    eval("${__ans}")
    return_ans()
  endfunction()






  function(listing)
    ref_new()
    return_ans()    
  endfunction()









  function(listing_combine)
    listing()
    ans(lst)
    foreach(listing ${ARGN})
      ref_get(${listing})
      ans(current)
      ref_append("${lst}" "${current}")
    endforeach()
    return(${lst})
  endfunction()








  function(listing_make_compile)
    listing()
    ans(uut)
    foreach(line ${ARGN})
      listing_append(${uut} "${line}")
    endforeach()
    listing_compile(${uut})
    return_ans()
  endfunction()







  function(listing_append_lines listing)
   foreach(line ${ARGN})
    listing_append(${listing} "${line}")
   endforeach()
  endfunction()






  function(listing_begin)
    listing()
    ans(lst)
    set(__listing_current "${lst}" PARENT_SCOPE)
  endfunction()





  function(listing_end)
    set(lst ${__listing_current})
    set(__listing_current PARENT_SCOPE)
    return_ref(lst)
  endfunction()






  function(listing_compile listing)
    ref_get("${listing}")
    ans(code)
    set(indent_on while if function foreach macro else elseif)
    set(unindent_on endwhile endif endfunction endforeach endmacro else elseif)
    set(current_indentation "")
    set(indented)


    foreach(line ${code})
      string(STRIP "${line}" line)
      string_take_regex(line "[^\\(]+")
      ans(func_name)
      if(func_name)
        list_contains(unindent_on ${func_name})
        ans(unindent)
        if(unindent)
          string_take(current_indentation "  ")
        endif()
        set(line "${current_indentation}${func_name}${line}")
        list_contains(indent_on ${func_name})
        ans(indent)
        if(indent)
          set(current_indentation "${current_indentation}  ")
        
        endif()
      endif()
      list(APPEND indented "${line}")
    endforeach()
    string(REPLACE ";" "\n" code "${indented}")
    string_semicolon_decode("${code}")
    ans(code)
    string(REPLACE "'" "\"" code "${code}")
    string(REGEX REPLACE "([^$]){([a-zA-Z0-9\\-_\\.]+)}" "\\1\${\\2}" code "${code}")
    return_ref(code)
  endfunction()






  macro(listing_end_compile)
    listing_end()
    listing_compile("${__ans}")
  endmacro()





    ## parses a property 
  function(property_def prop)
    data("${prop}")
    ans(prop)
    map_isvalid("${prop}")
    ans(ismap)

    if(ismap)
      return_ref(prop)
    endif()

    map_new()
    ans(res)


    string_take_regex(prop "[^:]+")
    ans(prop_name)

    if("${prop}_" STREQUAL "_")
      set(prop_type "any")
    else()
      string_take(prop :)
      set(prop_type "${prop}")
    endif()


    map_set(${res} property_name "${prop_name}")
    map_set(${res} display_name "${prop_name}")
    map_set(${res} property_type "${prop_type}")
    return_ref(res)
  endfunction()




# checks if the constraint holds for the specified version
function(semver_constraint_evaluate  constraint version)
  semver_constraint_compile("${constraint}")
  ans(compiled_constraint)
  #message("cc ${compiled_constraint}")
  if(NOT compiled_constraint)
    return(false)
  endif()
  semver_constraint_compiled_evaluate("${compiled_constraint}" "${version}")
  ans(res)
  #message("eval ${res}")
  return(${res})
endfunction()




function(semver string_or_version)
  if(NOT string_or_version)
    return()
  endif()
  map_isvalid(${string_or_version} )
  ans(ismap)
  if(ismap)
    return(${string_or_version})
  endif()
  semver_parse_lazy(${string_or_version})
  ans(version)
  return(${version})
endfunction()




#returns the version object iff the version  is valid
# else returns false
# validity:
# it has a major, minor and patch version field with valid numeric values [0-9]+
# accepts both a version string or a object
# 
function(semver_isvalid version)
  # get version object
  semver("${version}")
  ans(version)

  if(NOT version)
    return(false)
  endif()

#  nav(version.major)
  map_tryget(${version} major)
  ans(current)
  string_isnumeric( "${current}")
  ans(numeric)
  #message("curent ${current} : numeric ${numeric}")
  if(NOT numeric)
    return(false)
  endif()

  #nav(version.minor)
  map_tryget(${version} minor)
  ans(current)
  string_isnumeric("${current}")
  ans(numeric)
 # message("curent ${current} : numeric ${numeric}")
  if(NOT numeric)
    return(false)
  endif()

  #nav(version.patch)
  map_tryget(${version} patch)
  ans(current)
  string_isnumeric( "${current}")
  ans(numeric)
#  message("curent ${current} : numeric ${numeric}")
  if(NOT numeric)
    return(false)
  endif()

  return(true)
endfunction()




 function(semver_format version)
  semver_normalize("${version}")
  ans(version)

  #map_format("{version.major}.{version.minor}.{version.patch}")
  #ans(res)
  map_tryget(${version} major)
  ans(major)
  map_tryget(${version} minor)
  ans(minor)
  map_tryget(${version} patch)
  ans(patch)
  set(res "${major}.${minor}.${patch}")

  map_tryget("${version}" prerelease)
  ans(prerelease)
  if(NOT "${prerelease}_" STREQUAL "_")
    set(res "${res}-${prerelease}")
  endif()

  map_tryget("${version}" metadata)
  ans(metadata)
  if(NOT "${metadata}_" STREQUAL "_")
    set(res "${res}+${metadata}")
  endif()

  return_ref(res)

 endfunction()





function(semver_parse version_string)
  semver_parse_lazy("${version_string}")
  ans(version)
  if(NOT version)
    return()
  endif()


  semver_isvalid("${version}")
  ans(isvalid)
  if(isvalid)
    return(${version})
  endif()
  return()

  return()
  map_isvalid("${version_string}" )
  ans(ismap)
  if(ismap)
    semver_format(version_string ${version_string})
  endif()

 set(semver_identifier_regex "[0-9A-Za-z-]+")
 set(semver_major_regex "[0-9]+")
 set(semver_minor_regex "[0-9]+")
 set(semver_patch_regex "[0-9]+")
 set(semver_identifiers_regex "${semver_identifier_regex}(\\.${semver_identifier_regex})*") 
 set(semver_prerelease_regex "${semver_identifiers_regex}")
 set(semver_metadata_regex "${semver_identifiers_regex}")
 set(semver_version_regex "(${semver_major_regex})\\.(${semver_minor_regex})\\.(${semver_patch_regex})")
 set(semver_regex "(${semver_version_regex})(-${semver_prerelease_regex})?(\\+${semver_metadata_regex})?")

  cmake_parse_arguments("" "LAZY" "MAJOR;MINOR;PATCH;VERSION;VERSION_NUMBERS;PRERELEASE;METADATA;RESULT;IS_VALID" "" ${ARGN})

  map_new()
  ans(version)

  # set result to version (this will contain partial or all of the version information)
  if(_RESULT)
    set(${_RESULT} ${version} PARENT_SCOPE)
  endif()

  string(REGEX MATCH "^${semver_regex}$" match "${version_string}")
  # check if valid
  if(NOT match)
    set(${_IS_VALID} false PARENT_SCOPE)
    return()
  endif()
  set(${_IS_VALID} true PARENT_SCOPE)

  # get version metadata and comparable part
  string_split( "${version_string}" "\\+")
  ans(parts)
  list_pop_front(parts)
  ans(version_version)

  # get version number part and prerelease part
  string_split( "${version_version}" "-")
  ans(parts)
  list_pop_front(parts)
  ans(version_prerelease)
  
  # get version numbers
  string(REGEX REPLACE "^${semver_version_regex}$" "\\1" version_major "${version_number}")
  string(REGEX REPLACE "^${semver_version_regex}$" "\\2" version_minor "${version_number}")
  string(REGEX REPLACE "^${semver_version_regex}$" "\\3" version_patch "${version_number}")

  string(REGEX REPLACE "\\." "\;" version_metadata "${version_metadata}")
  string(REGEX REPLACE "\\." "\;" version_prerelease "${version_prerelease}")

  if(_MAJOR)
    set(${_MAJOR} ${version_major} PARENT_SCOPE)
  endif()
  if(_MINOR)
    set(${_MINOR} ${version_minor} PARENT_SCOPE)
  endif()
  if(_PATCH)
    set(${_PATCH} ${version_patch} PARENT_SCOPE)
  endif()

  if(_VERSION)
    set(${_VERSION} ${version_version} PARENT_SCOPE)
  endif()

  if(_VERSION_NUMBERS)
    set(${_VERSION_NUMBERS} ${version_number} PARENT_SCOPE)
  endif()

  if(_PRERELEASE)
    set(${_PRERELEASE} ${version_prerelease} PARENT_SCOPE)
  endif()

  if(_METADATA)
    set(${_METADATA} ${version_metadata} PARENT_SCOPE)
  endif()

  if(_RESULT)
    element(MAP res)
      value(KEY major "${version_major}")
      value(KEY minor "${version_minor}")
      value(KEY patch "${version_patch}")
      value(KEY prerelease "${version_prerelease}")
      value(KEY metadata "${version_metadata}")
    element(END)
    set(${_RESULT} ${res})
  endif()

endfunction()




# returns the semver which is higher of semver a  and b
   function(semver_higher a b)
    semver_gt("${a}" "${b}")
    ans(res)
    if(res)
      return(${a})
    else()
      return(${b})
    endif()
   endfunction()




# returns true if semver a is more up to date than semver b
  function(semver_gt  a b)
    semver_compare( "${a}" "${b}") 
    ans(res)
    ans(res)
    if(${res} LESS 0)
      return(true)
    endif()
    return(false)
  endfunction()




# returns a normalized version for a string or a object
# sets all missing version numbers to 0
# even an empty string is transformed to a version: it will be version 0.0.0 
function(semver_normalize version)
  semver("${version}")
  ans(version)

  if(NOT version)
    semver("0.0.0")
    ans(version)
  endif()

  nav(version.major)
  ans(current)
  if(NOT current)
    nav(version.major 0)
  endif() 


  nav(version.minor)
  ans(current)
  if(NOT current)
    nav(version.minor 0)
  endif() 


  nav(version.patch)
  ans(current)
  if(NOT current)
    nav(version.patch 0)
  endif() 

  return(${version})
endfunction()




# compares the semver on the left and right
# returns -1 if left is more up to date
# returns 1 if right is more up to date
# returns 0 if they are the same
function(semver_compare  left right)
 semver_parse(${left} )
 ans(left)
 semver_parse(${right})
 ans(right)


  scope_import_map(${left} left_)
  scope_import_map(${right} right_)

 semver_component_compare( ${left_major} ${right_major})
 ans(cmp)
 if(NOT ${cmp} STREQUAL 0)
  return(${cmp})
endif()
 semver_component_compare( ${left_minor} ${right_minor})
 ans(cmp)
 if(NOT ${cmp} STREQUAL 0)
  return(${cmp})
endif()
 
 semver_component_compare( ${left_patch} ${right_patch})
 ans(cmp)
 if(NOT ${cmp} STREQUAL 0)
  return(${cmp})
endif()


 if(right_prerelease AND NOT left_prerelease)
  return(-1)
 endif()

 if(left_prerelease AND NOT right_prerelease)
  return(1)
 endif()
 # iterate through all identifiers of prerelease
 while(true)
    list_pop_front(left_tags)
    ans(left_current)

    list_pop_front(right_tags)
    ans(right_current)

    # check for larger set
    if(right_current AND NOT left_current)
      return(1)
    elseif(left_current AND NOT right_current)
      return(-1)
    elseif(NOT left_current AND NOT right_current)
      # equal
      return(0)
    endif()

      # compare component
   semver_component_compare( ${left_current} ${right_current})
ans(cmp)

   #   message("asd '${left_current}'  '${right_current}' -> ${cmp}")
   if(NOT ${cmp} STREQUAL 0)
    return(${cmp})
   endif()



    
 endwhile()
 
 return(0)

endfunction()





function(semver_constraint_compiled_evaluate compiled_constraint version )
  nav("compiled_constraint.elements")
  ans(elements)
  nav("compiled_constraint.template")
  ans(template)

  #message("elements ${elements}")
  #message("template ${template}")
  foreach(element ${elements})
    semver_constraint_evaluate_element("${element}" "${version}")
    ans(res)
    string(REPLACE "${element}" "${res}" template "${template}")
  endforeach()
  if(${template})
    return(true)
  endif()
  return(false)
endfunction()





function(semver_constraint_evaluate_element constraint version)
  string(STRIP "${constraint}" constraint)
  set(constraint_operator_regexp "^(\\<|\\>|\\~|=|!)")
  set(constraint_regexp "${constraint_operator_regexp}?(.+)$")
  string(REGEX MATCH "${constraint_regexp}" match "${constraint}")
  if(NOT match )
    return_value(false)
  endif()
  set(operator)
  set(argument)

  string(REGEX MATCH "${constraint_operator_regexp}" has_operator "${constraint}")
  if(has_operator)
    string(REGEX REPLACE "${constraint_regexp}" "\\1" operator "${constraint}")
    string(REGEX REPLACE "${constraint_regexp}" "\\2" argument "${constraint}")      
  else()
    set(operator "=")
    set(argument "${constraint}")
  endif()

  # check for equality
  if(${operator} STREQUAL "=")
    semver_normalize("${argument}")    
    semver_format("${argument}")
    ans(argument)
    semver_compare( "${version}" "${argument}")
    ans(cmp)
    if("${cmp}" EQUAL "0")
      return(true)
    endif()
    return(false)
  endif()

  # check if version is greater than constraint
  if(${operator} STREQUAL ">")
    semver_normalize("${argument}")    
    semver_format("${argument}")
    ans(argument)
    semver_compare( "${version}" "${argument}")
    ans(cmp)
    if("${cmp}" LESS 0)
      return(true)
    endif()
    return(false)
  endif()

  # cheick  if version is less than constraint
  if(${operator} STREQUAL "<")
    semver_normalize("${argument}")    
    semver_format("${argument}")
    ans(argument)
    semver_compare( "${version}" "${argument}")
    ans(cmp)
    if("${cmp}" GREATER 0)
      return(true)
    endif()
    return(false)
  endif()

  if(${operator} STREQUAL "!")
    semver_normalize("${argument}")    
    semver_format("${argument}")
    ans(argument)
    semver_compare( "${version}" "${argument}")
    ans(cmp)
    if("${cmp}" EQUAL "0")
      return(false)
    endif()
    return(true)

  endif()

  #check if version about equal to constraint
  if(${operator} STREQUAL "~")
    string(REGEX REPLACE "(.*)([0-9]+)" "\\2" upper "${argument}")
    math(EXPR upper "${upper} + 1" )
    string(REGEX REPLACE "(.*)([0-9]+)" "\\1${upper}" upper "${argument}")
    string(REGEX REPLACE "(.*)([0-9]+)" "\\1\\2" lower "${argument}")
    
    semver_constraint_evaluate_element( ">${lower}" "${version}")
    ans(lower_ok_gt)
    semver_constraint_evaluate_element( "=${lower}" "${version}")
    ans(lower_ok_eq)
    semver_constraint_evaluate_element( "<${upper}" "${version}")
    ans(upper_ok)

    if((lower_ok_gt OR lower_ok_eq) AND upper_ok)
      return(true)
    endif()
    return(false)
  endif()
  return(false)
endfunction()





  function(semver_constraint_element_isvalid element)
    string(REGEX MATCH "^[~\\>\\<=!]?([0-9]+)(\\.[0-9]+)?(\\.[0-9]+)?(-[a-zA-Z0-9\\.-]*)?(\\+[a-zA-Z0-9\\.-]*)?$" match "${element}")
    if(match)
      return(true)
    else()
      return(false)
    endif()
  endfunction()





 function(semver_component_compare left right)
 # message("comapring '${left}' to '${right}'")
    string_isempty( "${left}")
    ans(left_empty)
    string_isempty( "${right}")
    ans(right_empty)

    # filled has precedence before nonempty
    if(left_empty AND right_empty)
      return(0)
    elseif(left_empty AND NOT right_empty)
      return(1)
    elseif(right_empty AND NOT left_empty)
      return(-1)
    endif() 


    string_isnumeric( "${left}")
    ans(left_numeric)
    string_isnumeric( "${right}")
    ans(right_numeric)

    # if numeric has precedence before alphanumeric
    if(right_numeric AND NOT left_numeric)
      return(-1)
    elseif(left_numeric AND NOT right_numeric)
      return(1)
    endif()


   
    if(left_numeric AND right_numeric)
      if(${left} LESS ${right})
        return(1)
      elseif(${left} GREATER ${right})
        return(-1)
      endif()
      return(0)
    endif()

    if("${left}" STRLESS "${right}")
      return(1)
    elseif("${left}" STRGREATER "${right}")
      return(-1)
    endif()

    return(0)
 endfunction()






function(semver_constraint constraint_ish)
  map_get_special(${constraint_ish} "semver_constraint")
  ans(is_semver_constraint)
  if(is_semver_constraint)
    return_ref(constraint_ish)
  endif()

  map_isvalid(${constraint_ish})
  ans(ismap)
  if(ismap)
    return()
  endif()

  # return cached value if it exists
 # cache_return_hit("${constraint_ish}")

  # compute and cache value
  semver_constraint_compile("${constraint_ish}")
  ans(constraint)
  # cache_update("${constraint_ish}" "${constraint}" const)

  return_ref(constraint)

endfunction()




function(semver_parse_lazy version_string)
  if(NOT version_string)
    return()
  endif()

  map_new()
  ans(version)
  map_set(${version} string "${version_string}")

  set(version_number_regex "[0-9]+")
  set(identifier_regex "[0-9a-zA-Z]+")
  set(version_numbers_regex "(${version_number_regex}(\\.${version_number_regex}(\\.${version_number_regex})?)?)")

  # checks if version is of ()-()+() structure and only contains valid characters
  set(version_elements_regex "([0-9\\.]*(-[a-zA-Z0-9\\.-]*)?(\\+[a-zA-Z0-9\\.-]*)?)")
  set(valid)
  string(REGEX MATCH "^${version_elements_regex}$" valid "${version_string}")
  if(NOT valid)
    return()
  endif()
  # split into version string and prelrelease metadata
  string_split_at_first(version_numbers prerelease_and_metadata "${version_string}" "-")
  string_split_at_first(prerelease metadata "${prerelease_and_metadata}" "+")
  # parse version numbers
  if(version_numbers)
    string(REGEX MATCH "^${version_numbers_regex}$" valid "${version_numbers}")
    if(NOT valid)
      return()
    endif()
    string(REPLACE "." ";" version_numbers "${version_numbers}")
    string(REPLACE "." ";" metadatas "${metadata}")
    string(REPLACE "." ";" tags "${prerelease}")
    list_extract(version_numbers major minor patch)
    map_set(${version} numbers "${version_numbers}")
    map_set(${version} major "${major}")
    map_set(${version} minor "${minor}")
    map_set(${version} patch "${patch}")
    #nav("version.numbers" "${version_numbers}")
    #nav("version.major" "${major}")
    #nav("version.minor" "${minor}")
    #nav("version.patch" "${patch}")
  endif()

  #nav("version.prerelease" "${prerelease}")
  #nav("version.metadata" "${metadata}")
  #nav("version.metadatas" "${metadatas}")
  #nav("version.tags" "${tags}")
  map_set(${version} prerelease "${prerelease}")
  map_set(${version} metadata "${metadata}")
  map_set(${version} metadatas "${metadatas}")
  map_set(${version} tags "${tags}")

  return(${version})
endfunction()





function(semver_constraint_compile constraint)
  set(ops "\\(\\)\\|,!=~><")
    
  if("${constraint}" STREQUAL "*")
    set(constraint ">=0.0.0")
  endif()
  string(REGEX REPLACE ">=([^${ops}]+)" "(>\\1|=\\1)" constraint "${constraint}")
  string(REGEX REPLACE "<=([^${ops}]+)" "(<\\1|=\\1)" constraint "${constraint}")


  string(REPLACE "!" ";NOT;" constraint "${constraint}")
  string(REPLACE "," ";AND;" constraint "${constraint}")
  string(REPLACE "|" ";OR;" constraint "${constraint}")
  string(REPLACE ")" ";);" constraint "${constraint}")
  string(REPLACE "(" ";(;" constraint "${constraint}")
  set(elements ${constraint})
  if(elements)
    list(REMOVE_DUPLICATES elements)
    list(REMOVE_ITEM elements "AND" "OR" "NOT" "(" ")" )
  endif()
  foreach(element ${elements})
    semver_constraint_element_isvalid(${element})
    ans(isvalid)
    if(NOT isvalid)
      return()
    endif()
  endforeach()
 # message("constraint ${constraint}")
 # message("elements ${elements}")
  nav(compiled_constraint.template "${constraint}")
  nav(compiled_constraint.elements "${elements}")
  map_set_special(${compiled_constraint} "semver_constraint" true)
  return(${compiled_constraint})

endfunction()






  function(project_load_packages)
    ## load all packages
    assign(installed_packages = this.dependency_source.query("?*"))

    foreach(installed_package ${installed_packages})
      assign(success = project_load_package(${installed_package}))
    endforeach()

    return()

  endfunction()







  ## this function is called after a package was successfully pulled
  ##
  function(project_install_package package_uri)
    assign(package_handle = this.dependency_source.resolve(${package_uri}))
    event_emit(project_on_package_install ${this} ${package_handle})
  endfunction()





  ## 
  ## events:
  ##   project_on_package_install(<project package> <package handle>)
  ##   project_on_package_load(<project package> <package handle>)
  function(project_install)
    set(args ${ARGN})
    list_pop_front(args)
    ans(uri)

    uri("${uri}")
    ans(uri)

    ## pull package from remote source to temp directory
    ## then push it into dependency_source from there
    ## return if anything did not work
    path_temp()
    ans(temp_dir)
    assign(project_dir = this.project_dir)
    assign(remote_package = this.remote.pull("${uri}" "${temp_dir}" ${args}))
    if(NOT remote_package)
      rm("${temp_dir}")
      log(--error "remote package could not be pulled: '{uri.input}'" uri temp_dir)
      return()
    endif()
    assign(package_uri = this.dependency_source.push("${remote_package}" ${args}))
    rm("${temp_dir}")
    if(NOT package_uri)
      log(--error "remote package could not pushed into project: '{uri.input}'" uri remote_package)
      return()
    endif()

    project_install_package("${package_uri}")
    project_load_package("${package_uri}")

    return_ref(package_uri)
  endfunction()




## project_create(<project dir> <project config?>) -> <project handle>
##
## creates a project in the specified directory
##
## --force flag deletes all data in the specified project dir 
function(project_create)
  set(args ${ARGN})

  list_extract_flag(args --force)
  ans(force)


  list_pop_front(args)
  ans(project_dir)
  path_qualify(project_dir)

  list_pop_front(args)
  ans(config)
  
  project_config("${config}")
  ans(config)


  if(IS_DIRECTORY "${project_dir}")
      dir_isempty("${project_dir}")
      ans(isempty)
      if(NOT isempty)
        if(force)
        else()
          ## todo: try to create project from existing files
          log(--error "trying to create a project in a non-empty directory (${project_dir}) (use --force if intendend)")
          return()
        endif()
      endif()
  else()
    if(EXISTS "${project_dir}")
      if(NOT force)
        log(--error "specified project_dir ({project_dir}) is an existing file")
        return()
      endif()
      rm("${project_dir}")
      mkdir("${project_dir}")
    else()
      mkdir("${project_dir}")
    endif()
  endif()

  project_new()
  ans(project)


  assign(success = project.load("${project_dir}" "${config}"))

  if(NOT success)
      return()
  endif()

  assign(success = project.save())
  if(NOT success)
    return()
  endif()

  return_ref(project)
endfunction()





## project_save(<config file path?>) -> <bool>
##
## saves the current project configuration to 
## the specified config file path.  if no path 
## is given the project is saved to the default location
##
##
function(project_save)
  set(args ${ARGN})

  assign(project_dir = this.project_dir)

  list_pop_front(args)
  ans(config_file)

  if(NOT config_file)
    assign(config_file = this.configuration.config_file)
    path_qualify_from("${project_dir}" "${config_file}")
    ans(config_file)
  else()
    path_qualify(config_file)
  endif()


  ## save package descriptor
  assign(package_descriptor_file = this.configuration.package_descriptor_file)
  path_qualify_from("${project_dir}" "${package_descriptor_file}")
  ans(package_descriptor_file)
  assign(package_descriptor = this.package_descriptor)
  fwrite_data("${package_descriptor_file}" "${package_descriptor}")

  ## save project config
  assign(configuration = this.configuration)
  fwrite_data("${config_file}" "${configuration}")



  return(true)
endfunction()







  ## package load is called for every installed package in arbitrary order
  ## here things which do not dependend on other packages can be done
  function(project_load_package package_uri)
    assign(package_handle = this.dependency_source.resolve(${package_uri}))
    event_emit(project_on_package_load ${this} ${package_handle})
  endfunction()




## parses the project config
function(project_config )
  set(args "${ARGN}")

  list_pop_front(args)
  ans(config)
  if(NOT config STREQUAL "" 
     AND EXISTS "${config}" 
     AND NOT IS_DIRECTORY "${config}")
    fread_data("${config}")
    ans(config)
    if(NOT config)
      return()
    endif()
  else()
    obj("${config}")
    ans(config)
  endif()

  map_defaults(
    "${config}"
  "{
    config_dir:'.cps',
    content_dir:'.',
    dependency_dir:'packages',
    config_file:'.cps/config.qm',
    package_descriptor_file:'.cps/package_descriptor.qm'
  }")
  ans(config)

  return_ref(config)

endfunction()




## project_load(project dir <~project config?>) -> bool
##
## 
## events:
##   project_on_load(<project package>)
##   project_on_begin_load(<project package>)
##   project_on_package_load(<project package> <package handle>)
##
function(project_load)
  set(args ${ARGN})

  ## qualify project_dir
  list_pop_front(args)
  ans(project_dir)
  path_qualify(project_dir)
  assign(this.project_dir = project_dir)

  ## parse and set project config
  project_config(${args})
  ans(project_config)
  assign(this.configuration = project_config)

  event_emit(project_on_begin_load ${this} ${project_config})

  ## qualify directories relative to project dir
  map_import_properties(${project_config} 
    content_dir 
    config_dir 
    dependency_dir
    package_descriptor_file
  )

  path_qualify_from("${project_dir}" "${package_descriptor_file}")
  ans(package_descriptor_file)
  path_qualify_from("${project_dir}" "${content_dir}")
  ans(content_dir)
  path_qualify_from("${project_dir}" "${config_dir}")
  ans(config_dir)
  path_qualify_from("${project_dir}" "${dependency_dir}")
  ans(dependency_dir)


  ## set directories
  assign(this.content_dir = content_dir)
  assign(this.config_dir = config_dir)
  assign(this.dependency_dir = dependency_dir)

  ## load package descriptor
  fread_data("${package_descriptor_file}")
  ans(package_descriptor)
  assign(this.package_descriptor = package_descriptor)


  ## create package source for project
  managed_package_source("project" "${dependency_dir}")
  ans(dependency_source)
  assign(this.dependency_source = dependency_source)

  ## load all installed packages
  project_load_packages()  

  ## emit loaded event
  event_emit(project_on_load ${this})  
  return(true)
endfunction()






  ## project_new() -> <project package>
  ## creates a new project package
  ## 
  ## a <project package> is bound to a directory and manages installed
  ## packages
  ## 
  ## it has a remote package source which is queried to install packages
  ## and a local managed package source (dependency_source) which manages
  ## installed packages
  ##
  function(project_new)
    default_package_source()
    ans(default_source)
    obj("{
      load:'project_load',
      save:'project_save',
      install:'project_install',
      uninstall:'project_uninstall',
      remote:$default_source,
      config_dir: '.cps',
      dependency_dir: 'packages'
    }")
    ans(project)
    return_ref(project)
  endfunction()




  ## project_open(<path?>) -> <project>|<null>
  ##
  ## opens an existing project if project does not exist null is returned
  ## if s
  function(project_open)
    set(args ${ARGN})
    list_pop_front(args)
    ans(path)

    path_qualify(path)

    set(project_dir)
    if(IS_DIRECTORY "${path}")
      # assume path is project dir -> try to read project config file
      set(project_dir "${path}")
      set(path "${path}/.cps/config.qm")
    endif()


    if(NOT EXISTS "${path}")
      log(--error "could not find project configuration at {path}")
      return()
    endif()

    project_config("${path}")
    ans(config)
    

    if(NOT project_dir)
      map_tryget("${config}" config_file)
      ans(config_file)
      
      string_remove_ending("${path}" "${config_file}")
      ans(project_dir)

      path_qualify(project_dir)
    endif()

    project_new()
    ans(project)


    call(project.load("${project_dir}" "${config}"))
    ans(success)

    if(NOT success)
      return()
    endif()



    return_ref(project)
  endfunction()







  ## 
  ## events:
  ##   project_on_package_uninstall(<project package> <package handle>)
  function(project_uninstall uri)
    uri("${uri}")
    ans(uri)

    assign(installed_package = this.dependency_source.resolve("${uri}"))

    if(NOT installed_package)
      log(--error "package '{uri.input}' does not exist in project")
      return()
    endif()

    event_emit(project_on_package_uninstall ${this} ${installed_package})

    map_import_properties(${installed_package} managed_dir)
    rm("${managed_dir}")

    return(true)
  endfunction()





  function(package_handle)
    map_tryget("${ARGN}" package_descriptor)
    ans(pd)
    map_tryget("${ARGN}" content_dir)
    ans(content_dir)

    path_qualify(content_dir)

    map_isvalid("${pd}")
    ans(ismap)
    if(ismap AND content_dir AND IS_DIRECTORY "${content_dir}")
      return(${ARGN})
    endif()

    set(args ${ARGN})
    list_extract(args content_dir package_descriptor)

    path_qualify(content_dir)



    obj("${package_descriptor}")
    ans(pd)

    if(NOT pd)
      if(NOT IS_DIRECTORY "${content_dir}")
        return()
      endif()

      json_read("${content_dir}/package.cmake")
      ans(pd)
 
      if(NOT pd)
        return()
      endif()

    endif()


    map_new()
    ans(package_handle)
    map_set(${package_handle} package_descriptor ${pd})
    map_set(${package_handle} content_dir ${content_dir})
    return(${package_handle})

  endfunction()






  function(package_source_pull_svn uri)
    set(args ${ARGN})

    package_source_query_svn("${uri}")
    ans(valid_uri_string)

    list(LENGTH valid_uri_string uri_count)
    if(NOT uri_count EQUAL 1)
      return()
    endif()

    uri("${valid_uri_string}")
    ans(uri)


    uri_format("${uri}" --no-query --remove-scheme svnscm)
    ans(remote_uri)

    list_pop_front(args)
    ans(target_dir)
    path_qualify(target_dir)

    ## branch / tag / trunk / revision
    assign(svn_revision = uri.params.revision)
    assign(svn_branch = uri.params.branch)
    assign(svn_tag = uri.params.tag)
    if(NOT svn_revision STREQUAL "")
      set(svn_revision --revision "${svn_revision}")
    endif() 

    if(NOT svn_branch STREQUAL "")
      set(svn_branch --branch "${svn_branch}")
    endif() 

    if(NOT svn_tag STREQUAL "")
      set(svn_tag --tag "${svn_tag}")
    endif() 

    svn_cached_checkout("${remote_uri}" "${target_dir}" ${revision} ${branch} ${tag})
    ans(success)

    if(NOT success)
      return()
    endif()


    ## package_descriptor
    package_handle("${target_dir}")
    ans(package_handle)

    map_tryget("${package_handle}" package_descriptor)
    ans(package_descriptor)


    ## response
    map_new()
    ans(result)
    map_set("${result}" package_descriptor "${package_descriptor}")
    map_set("${result}" uri "${valid_uri_string}")
    map_set("${result}" content_dir "${target_dir}")
    return(${result})

  endfunction()







  function(package_source_resolve_svn uri)
    package_source_query_svn("${uri}")
    ans(valid_uri_string)
    list(LENGTH valid_uri_string uri_count)

    if(NOT uri_count EQUAL 1)
      return()
    endif()



    svn_uri_analyze("${valid_uri_string}")
    ans(svn_uri)

    map_import_properties(${svn_uri} base_uri ref_type ref revision)

    string(REGEX REPLACE "^svnscm\\+" "" base_uri "${base_uri}")
    if(NOT revision)
      set(revision HEAD)
    endif()


    if("${ref_type}" STREQUAL "branch")
      set(ref_type branches)
    elseif("${ref_type}" STREQUAL "tag")
      set(ref_type tags)
    endif()
    set(checkout_uri "${base_uri}/${ref_type}/${ref}/package.cmake@${revision}")
    
    file_make_temporary("")
    ans(tmp)
    rm(${tmp})
    svn(export "${checkout_uri}" "${tmp}" --return-code)
    ans(error)

    if(NOT error)
      package_handle("${tmp}")
      ans(package_handle)

      map_tryget("${package_handle}" package_descriptor)
      ans(package_descriptor)
      rm(tmp)
    endif()

    string(REGEX MATCH "[^/]+$" default_id "${base_uri}")

    map_defaults("${package_descriptor}" "{
      id:$default_id,
      version:'0.0.0'
    }")
    ans(package_descriptor)
    ## response
    map_new()
    ans(package_handle)

    map_set(${package_handle} package_descriptor "${package_descriptor}")
    map_set(${package_handle} uri "${valid_uri_string}")

    return_ref(package_handle)
  endfunction()





  function(package_source_query_svn uri)
    set(input_uri "${uri}")
    uri("${uri}")
    ans(uri)

    svn_uri_analyze("${uri}")
    ans(svn_uri)

    svn_uri_format_ref("${svn_uri}")
    ans(ref_uri)

    svn_remote_exists("${ref_uri}")
    ans(remote_exists)

    if(NOT remote_exists)
      return()
    endif()

    svn_uri_format_package_uri("${svn_uri}")
    ans(package_uri)

    return("svnscm+${package_uri}")
  endfunction()





  function(svn_package_source)
    obj("{
      source_name:'svnscm',
      pull:'package_source_pull_svn',
      query:'package_source_query_svn',
      resolve:'package_source_resolve_svn'
    }")
    return_ans()
  endfunction()






  function(package_source_best_match __lst uri)
    uri("${uri}")
    ans(uri)

    list_to_map(${__lst} "(m)->map_tryget($m source_name)")
    ans(map)

    map_tryget("${uri}" schemes)
    ans(schemes)
    

    set(source)
    foreach(scheme ${schemes})
      map_tryget(${map} ${scheme})
      ans(source)
      if(source)
        break()
      endif()
    endforeach()

    if(NOT source)
      list_peek_front(${__lst})
      ans(source)
    endif()
    return_ref(source)
  endfunction()

  function(package_source_rate package_source uri)
    uri("${uri}")
    ans(uri)

    return(0)
  endfunction()
  





  function(package_source_query_bitbucket uri)
    uri("${uri}")
    ans(uri)

    assign(segments = uri.normalized_segments)
    list_extract(segments owner repo)

    set(api_uri "https://api.bitbucket.org/2.0")

    if("${owner}_" STREQUAL "_")
      return()
    endif()

    if("${repo}_" STREQUAL "_")
      set(request_uri "${api_uri}/repositories/${owner}")
    else()
      set(request_uri "${api_uri}/repositories/${owner}/${repo}")
    endif() 
    
    http_get("${request_uri}" "")
    ans(response)
    map_tryget(${response} client_status)
    ans(error)
    if(error)
      return()
    endif()

    if(NOT "${repo}_" STREQUAL "_")
      set(result "bitbucket:${owner}/${repo}")
    else()
      set(repos)
      while(true)
        map_tryget(${response} content)
        ans(content)
        
        json_extract_string_value(next "${content}")
        ans(next_uri)
      
        json_extract_string_value("name" "${content}")
        ans(names)

        list(APPEND repos ${names})

        if(NOT next_uri)
          break()
        endif()

        http_get("${next_uri}" "")
        ans(response)
        map_tryget(${response} client_status)
        ans(error)
        if(error)
          message(WARNING "failed to query host ${next_uri} ${error}")
          return()
        endif()
      endwhile()   
      list_remove_duplicates(repos)
      list_remove(repos ssh https)# hack: these are different name properties

      set(result)
      ## possibly this should recursively check if the repo really exists
      foreach(repo ${repos})
        list(APPEND result "bitbucket:${owner}/${repo}")
      endforeach()
    endif()  

    return_ref(result)
  endfunction()






  function(package_source_pull_bitbucket uri)
    set(args ${ARGN})

    list_extract_flag(args --use-ssh)
    ans(use_ssh)

    package_source_resolve_bitbucket("${uri}")
    ans(package_handle)

    if(NOT package_handle)
      return()
    endif()

    list_pop_front(args)
    ans(target_dir)

    map_tryget(${package_handle} package_descriptor)
    ans(package_descriptor)

    map_tryget(${package_handle} repo_descriptor)
    ans(repo_descriptor)

    map_tryget(${repo_descriptor} scm)
    ans(scm)

    assign(clone_locations = repo_descriptor.links.clone)
    map_new()
    ans(clone)
    foreach(clone_location ${clone_locations})
      map_import_properties(${clone_location} name href)
      map_set(${clone} ${name} ${href})
    endforeach()

    if(use_ssh)
      set(clone_method ssh)
    else()
      set(clone_method https)
    endif()

    map_tryget(${clone} "${clone_method}")
    ans(clone_uri)


    ## depending on scm pull git or hg
    if(scm STREQUAL "git")
      package_source_pull_git("${clone_uri}" "${target_dir}")
      ans(scm_package_handle)
    elseif(scm STREQUAL "hg")
      package_source_pull_hg("${clone_uri}" "${target_dir}")
      ans(scm_package_handle)
    else()
      message(FATAL_ERROR "scm not supported: ${scm}")
    endif()

    map_tryget("${scm_package_handle}" package_descriptor)
    ans(scm_package_descriptor)

    map_tryget("${scm_package_handle}" content_dir)
    ans(scm_content_dir)
      
    map_defaults("${package_descriptor}" "${scm_package_descriptor}")

    map_set("${package_handle}" content_dir "${scm_content_dir}")

    return_ref(package_handle)
  endfunction()





  function(package_source_resolve_bitbucket uri)
    uri("${uri}")
    ans(uri)
    
    ## query for a valid and single  bitbucket uris 
    package_source_query_bitbucket("${uri}")
    ans(valid_uri_string)
    list(LENGTH valid_uri_string uri_count)
    if(NOT uri_count EQUAL 1)
      return()
    endif()

    ## get owner repo and ref
    uri("${valid_uri_string}")
    ans(valid_uri)

    map_tryget(${valid_uri} normalized_segments)
    ans(segments)

    list_extract(segments owner repo ref)


    ## get repo descriptor (return if not found)
    set(api_uri "https://api.bitbucket.org/2.0")
    set(request_uri "${api_uri}/repositories/${owner}/${repo}" )

    http_get("${request_uri}" "" --json)
    ans(repo_descriptor)

    if(NOT repo_descriptor)
      return()
    endif()

    ## if no ref is set query the bitbucket api for main branch
    if("${ref}_" STREQUAL "_")
      ## get the main branch
      set(main_branch_request_uri "https://api.bitbucket.org/1.0/repositories/${owner}/${repo}/main-branch")

      http_get("${main_branch_request_uri}" "" --json)
      ans(response)
      assign(main_branch = response.name)
      set(ref "${main_branch}")  
    endif()

    set(path package.cmake)

    ## try to get an existing package descriptor by downloading from the raw uri
    set(raw_uri "https://bitbucket.org/${owner}/${repo}/raw/${ref}/${path}")

    http_get("${raw_uri}" "" --json)
    ans(package_descriptor)

    ## setup package descriptor default value

    map_defaults("${package_descriptor}" "{
      id:$repo_descriptor.full_name, 
      version:'0.0.0',
      description:$repo_descriptor.description
    }")
    ans(package_descriptor)

    ## response
    map_new()
    ans(result)
    map_set(${result} package_descriptor "${package_descriptor}")
    map_set(${result} uri "${valid_uri_string}")
    map_set(${result} repo_descriptor "${repo_descriptor}")

    return(${result})
  endfunction()




  function(bitbucket_package_source)
    obj("{
      source_name:'bitbucket',
      pull:'package_source_pull_bitbucket',
      query:'package_source_query_bitbucket',
      resolve:'package_source_resolve_bitbucket'
    }")
    return_ans()
  endfunction()






## pull_package(<~uri> <?target dir>|[--reference]) -> <package handle>
##
## --reference flag causes pull to return an existing content_dir in package handle if possible
##             <null> is returned if pulling a reference is not possbile
##
## <target dir> the <unqualified path< were the package is to be pulled to
##              the default is the current directory
##
##  pull the specified package to the target location. the package handle contains
##  meta information about the package like the package uri, package_descriptor, content_dir ...
function(pull_package)
  default_package_source()
  ans(source)
  call(source.pull(${ARGN}))
  return_ans()
endfunction()





## returns a list of valid package uris which contain the scheme gitscm
## you can specify a query for ref/branch/tag by adding ?ref=* or ?ref=name
## only ?ref=* returns multiple uris
  function(package_source_query_git uri_string)
    set(args ${ARGN})

    list_extract_flag(args --package-handle)
    ans(return_package_handle)

    uri("${uri_string}")
    ans(uri)

    map_tryget("${uri}" schemes)
    ans(scheme)

    list_extract_flag(scheme gitscm)
    ans(is_gitscm)

    map_set(${uri} scheme "${scheme}")


    uri_qualify_local_path("${uri}")
    ans(uri)

    uri_format("${uri}" --no-query --remove-scheme gitscm)
    ans(remote_uri)

    ## check if remote exists
    git_remote_exists("${remote_uri}")
    ans(remote_exists)


    ## remote does not exist
    if(NOT remote_exists)
      return()
    endif()

    ## get ref and check if it exists
    assign(ref = uri.params.ref)
    assign(branch = uri.params.branch)  
    assign(tag = uri.params.tag)
    assign(rev = uri.params.rev)

    set(ref ${ref} ${branch} ${tag})
    list_pop_front(ref)
    ans(ref)

    if(NOT "${rev}_" STREQUAL "_")
      ## todo validate rev?
      if(NOT "${rev}" MATCHES "^[a-fA-F0-9]+$")
        return()
      endif()

      set(result "gitscm+${remote_uri}?rev=${rev}")
      if(return_package_handle)
        map_new()
        ans(package_handle)

        assign(!package_handle.uri = result)
        assign(!package_handle.query_uri = uri_string)
        assign(!package_handle.scm_descriptor.scm = 'git')
        assign(!package_handle.scm_descriptor.ref.revision = rev)
        assign(!package_handle.scm_descriptor.ref.type = '')
        assign(!package_handle.scm_descriptor.ref.name = '')
        set(result ${package_handle})
      endif()
    elseif("${ref}_" STREQUAL "*_")
      ## get all remote refs and format a uri for every found tag/branch
      git_remote_refs("${remote_uri}")
      ans(refs)
      set(result)
      foreach(ref ${refs})
        map_tryget(${ref} name)
        ans(ref_name)
        map_tryget(${ref} type)
        ans(ref_type)
        map_tryget(${ref} revision)
        ans(revision)
        if("${ref_type}" STREQUAL "tags" OR "${ref_type}" STREQUAL "heads")
          if("${ref_type}" STREQUAL "tags")
            set(ref_type tag)
          elseif("${ref_type}" STREQUAL "heads")
            set(ref_type branch)
          else()
            set(ref_type ref)
          endif()
          set(current_uri "gitscm+${remote_uri}?rev=${revision}")
          #list(APPEND result "gitscm+${remote_uri}?${ref_type}=${ref_name}")
          if(return_package_handle)
            map_new()
            ans(package_handle)

            assign(!package_handle.uri = current_uri)
            assign(!package_handle.query_uri = uri_string)
            assign(!package_handle.scm_descriptor.scm = 'git')
            assign(!package_handle.scm_descriptor.ref = ref)
            list(APPEND result ${package_handle})
          else()
            list(APPEND result "${current_uri}")
          endif()
        endif()
      endforeach()
    elseif(NOT "${ref}_" STREQUAL "_")
      ## ensure that the specified ref exists and return a valid uri if it does
      git_remote_ref("${remote_uri}" "${ref}" "*")
      ans(ref)
      if(NOT ref)
        return()
      endif()
      map_tryget(${ref} type)
      ans(ref_type)

      map_tryget(${ref} revision)
      ans(revision)
      if("${ref_type}" STREQUAL "heads")
        set(ref_type branch)
      elseif("${ref_type}" STREQUAL "tags")
        set(ref_type tag)
      else()
        set(ref_type ref)
      endif()
      map_tryget(${ref} name)
      ans(ref_name)

      #set(result "gitscm+${remote_uri}?${ref_type}=${ref_name}")
      set(result "gitscm+${remote_uri}?rev=${revision}")
      if(return_package_handle)
        map_new()
        ans(package_handle)
        assign(!package_handle.uri = result)
        assign(!package_handle.query_uri = uri_string)
        assign(!package_handle.scm_descriptor.scm = 'git')
        assign(!package_handle.scm_descriptor.ref = ref)

        set(result ${package_handle})
      endif()
    else()
      git_remote_ref("${remote_uri}" "HEAD" "*")
      ans(tip)
      map_tryget("${tip}" revision)
      ans(revision)
      ## use the default (no ref)
      set(result "gitscm+${remote_uri}?rev=${revision}")

      if(return_package_handle)
        map_new()
        ans(package_handle)
        assign(!package_handle.uri = result)
        assign(!package_handle.query_uri = uri_string)
        assign(!package_handle.scm_descriptor.scm = 'git')
        assign(!package_handle.scm_descriptor.ref = tip)
        set(result ${package_handle})
      endif()
    endif()


    
    return_ref(result)
  endfunction()




## package_source_pull_git(<~uri> <path?>)
## pulls the package described by the uri  into the target_dir
## e.g.  package_source_pull_git("https://github.com/toeb/cutil.git?ref=devel")
  function(package_source_pull_git uri)
    set(args ${ARGN})

    package_source_query_git("${uri}" --package-handle)
    ans(package_handle)
    list(LENGTH package_handle uri_count)
    ## require single valid uri
    if(NOT uri_count EQUAL 1)
      return()
    endif()

    map_tryget(${package_handle} uri)
    ans(valid_uri_string)

    uri("${valid_uri_string}")
    ans(uri)

    uri_format("${uri}" --no-query --remove-scheme gitscm)
    ans(remote_uri)

    list_pop_front(args)
    ans(target_dir)
    path_qualify(target_dir)

    assign(rev = uri.params.rev)

    git_cached_clone("${target_dir}" "${remote_uri}" "${rev}")
    ans(target_dir)

    package_handle("${target_dir}")
    ans(local_package_handle)

    map_tryget(${uri} file_name)
    ans(default_id)

    map_tryget("${local_package_handle}" package_descriptor)
    ans(package_descriptor)

    map_defaults("${package_descriptor}" "{
      id:$default_id,
      version:'0.0.0'
    }")
    ans(package_descriptor)

    map_set(${package_handle} package_descriptor "${package_descriptor}")
    map_set(${package_handle} content_dir "${target_dir}")

    return_ref(package_handle)
  endfunction()   






## returns a pacakge descriptor for the specified git uri 
## takes long for valid uris because the whole repo needs to be checked out
function(package_source_resolve_git uri_string)
  set(args ${ARGN})

  file_tempdir()
  ans(temp_dir)

  package_source_pull_git("${uri_string}" "${temp_dir}")
  ans(res)

  if(NOT res)
    return()
  endif() 
  
  return_ref(res)
endfunction()







  function(git_package_source)
    obj("{
      source_name:'gitscm',
      pull:'package_source_pull_git',
      query:'package_source_query_git',
      resolve:'package_source_resolve_git'
    }")
    return_ans()
  endfunction()





## package_source_pull_github(<~uri> <?target_dir>) -> <package handle>
function(package_source_pull_github uri)
  set(args ${ARGN})

  ## get package descriptor 
  package_source_resolve_github("${uri}")
  ans(package_handle)
  if(NOT package_handle)
    return()
  endif()

  ## get path
  list_pop_front(args)
  ans(target_dir)
  path_qualify(target_dir)

  ## retreive the hidden/special repo_descriptor
  ## to gain access to the clone url
  map_tryget(${package_handle} repo_descriptor)
  ans(repo_descriptor)

  map_tryget(${package_handle} package_descriptor)
  ans(package_descriptor)

  ## alternatives git_url/clone_url
  map_tryget(${repo_descriptor} clone_url)
  ans(clone_url)


  package_source_pull_git("${clone_url}" "${target_dir}")
  ans(scm_package_handle)

  if(NOT scm_package_handle)
    return()
  endif()

  map_tryget("${scm_package_handle}" package_descriptor)
  ans(scm_package_descriptor)

  map_defaults("${package_descriptor}" "${scm_package_descriptor}")

  map_tryget("${scm_package_handle}" content_dir)
  ans(scm_content_dir)

  map_set("${package_handle}" content_dir "${scm_content_dir}")

  return_ref(package_handle)

endfunction()





  function(github_package_source)
    obj("{
      source_name:'github',
      pull:'package_source_pull_github',
      query:'package_source_query_github',
      resolve:'package_source_resolve_github'
    }")
    return_ans()
  endfunction()







  ## resolves the specifie package uri 
  ## and if uniquely identifies a package 
  ## returns its pacakge descriptor
  function(package_source_resolve_github uri)  
    set(github_api_token "?client_id=$ENV{GITHUB_DEVEL_TOKEN_ID}&client_secret=$ENV{GITHUB_DEVEL_TOKEN_SECRET}")

    ## get a single valid github package source uri
    ## or return
    package_source_query_github("${uri}")
    ans(valid_uri_string)

    list(LENGTH valid_uri_string uri_count)
    if(NOT ${uri_count} EQUAL 1)
      return()
    endif()



    uri("${valid_uri_string}")
    ans(valid_uri)

    ## get owner and repository and use it to format url
    assign(owner = valid_uri.normalized_segments[0])
    assign(repo = valid_uri.normalized_segments[1])

    set(api_uri "https://api.github.com")
    set(repo_uri "${api_uri}/repos/${owner}/${repo}${github_api_token}")

    ## get the repository descriptor
    http_get("${repo_uri}" "")
    ans(res)
    assign(content = res.content)
    json_deserialize("${content}")
    ans(repo_descriptor)


    ## try to get the package descriptor remotely
    set(ref master)
    set(path package.cmake)
    set(raw_uri "https://raw.githubusercontent.com/")
    set(package_descriptor_uri "${raw_uri}/${owner}/${repo}/${ref}/${path}" )

    http_get("${package_descriptor_uri}" "")
    ans(package_descriptor_response)

    assign(package_descriptor_content = package_descriptor_response.content)

    json_deserialize("${package_descriptor_content}")
    ans(package_descriptor)


    ## map default values on the packge descriptor 
    ## using the information from repo_descriptor
    assign(description = repo_descriptor.description)

    map_defaults("${package_descriptor}" "{
      id:$repo,
      version:'0.0.0',
      description:$description
    }")
    ans(package_descriptor)
    
    ## response
    map_new()
    ans(result)
    map_set(${result} package_descriptor "${package_descriptor}")
    map_set(${result} uri "${valid_uri_string}")
    map_set(${result} repo_descriptor "${repo_descriptor}")

    return_ref(result)
  endfunction()




## queries github to find all packages of a specified user 
## or a specific repository by owner/reponame
## returns a list of valid package uris
function(package_source_query_github uri)
  set(github_api_token "?client_id=$ENV{GITHUB_DEVEL_TOKEN_ID}&client_secret=$ENV{GITHUB_DEVEL_TOKEN_SECRET}")

  set(api_uri "https://api.github.com")

  ## parse uri and extract the two first segments 
  uri("${uri}")
  ans(uri)

  assign(segments = uri.normalized_segments)
  list_extract(segments user repo)
  if(NOT user)
    return()
  endif()
  
  if(repo)
    ## check if a single repository exists
    http_get("${api_uri}/repos/${user}/${repo}${github_api_token}" "")
    ans(res)
    assign(error = res.client_status)
    if(error)
      return()
    endif()
    return("github:${user}/${repo}")
  else()
    ## check for all repositories

    http_get("${api_uri}/users/${user}/repos${github_api_token}" "")
    ans(res)
    assign(error = res.client_status)
    if(error)
      return()
    endif()
    assign(content = res.content)
    
    ## this is a quick way to get all full_name fields of the unparsed json
    ## parsing large json files would be much too slow
    regex_escaped_string("\"" "\"") 
    ans(regex)
    set(full_name_regex "\"full_name\" *: ${regex}")
    string(REGEX MATCHALL  "${full_name_regex}" matches "${content}")
    set(github_urls)
    foreach(match ${matches})
      string(REGEX REPLACE "${full_name_regex}" "\\1" match "${match}")
      list(APPEND github_urls "github:${match}")
    endforeach() 


    return_ref(github_urls)
  endif()
endfunction()








  function(default_package_source)
    set(sources)

    path_package_source()
    ans_append(sources)
    
    archive_package_source()
    ans_append(sources)

    webarchive_package_source()
    ans_append(sources)

    find_package(Git)
    find_package(Hg)
    find_package(Subversion)

    if(GIT_FOUND)
      github_package_source()
      ans_append(sources)
    endif()    
  
    if(GIT_FOUND AND HG_FOUND)
      bitbucket_package_source()
      ans_append(sources)
    endif()
    
    if(GIT_FOUND)
      git_package_source()
      ans_append(sources)
    endif()

    if(HG_FOUND)
      hg_package_source()
      ans_append(sources)
    endif()

    if(SUBVERSION_FOUND)
      svn_package_source()
      ans_append(sources)
    endif()

    composite_package_source("" ${sources})
    ans(default_package_source)
    map_set(global default_package_source ${default_package_source})
    function(default_package_source)
      map_get(global default_package_source)
      return_ans()
    endfunction()
    return_ans()
  endfunction()








  function(package_source_resolve_hg uri)
    file_tempdir()
    ans(temp_dir)

    package_source_pull_hg("${uri}" "${temp_dir}")
    ans(package_handle)

    if(NOT package_handle)
      return()
    endif()


    return_ref(package_handle)
  endfunction()






  function(package_source_pull_hg uri)
    set(args ${ARGN})


    package_source_query_hg("${uri}" ${args})
    ans(valid_uri_string)
    
    list(LENGTH valid_uri_string uri_count)
    ## require single valid uri
    if(NOT uri_count EQUAL 1)
      return()
    endif()

    uri("${valid_uri_string}")
    ans(uri)


    uri_format("${uri}" --no-query --remove-scheme "hgscm")
    ans(remote_uri)

    list_pop_front(args)
    ans(target_dir)


    ## get ref
    assign(ref = uri.params.ref)
    assign(branch = uri.params.branch)  
    assign(tag = uri.params.tag)
    set(ref ${ref} ${branch} ${tag})
    list_pop_front(ref)
    ans(ref)

    hg_cached_clone("${target_dir}" "${remote_uri}" "${ref}")
    ans(target_dir)

    package_handle("${target_dir}")
    ans(package_handle)

    map_tryget("${package_handle}" package_descriptor)
    ans(package_descriptor)

    map_tryget(${uri} file_name)
    ans(default_id)

    map_defaults("${package_descriptor}" "{
      id:$default_id,
      version:'0.0.0'
    }")
    ans(package_descriptor)

    ## response
    map_new()
    ans(result)
    map_set(${result} package_descriptor ${package_descriptor})
    map_set(${result} uri "${valid_uri_string}")
    map_set(${result} content_dir "${target_dir}")

    return_ref(result)
  endfunction()





  function(hg_package_source)
    obj("{
      source_name:'hgscm',
      pull:'package_source_pull_hg',
      query:'package_source_query_hg',
      resolve:'package_source_resolve_hg'
    }")
    return_ans()
  endfunction()






## package_source_query_hg(<~uri>) -> <uri>|<package handle>

  function(package_source_query_hg uri)
    set(args ${ARGN})
    list_extract_flag(args --package-handle)
    ans(return_package_handle)

    uri("${uri}")
    ans(uri)

    map_tryget("${uri}" schemes)
    ans(scheme)

    list_extract_flag(scheme hgscm)
    ans(is_hgscm)

    map_set(${uri} scheme "${scheme}")

    list(LENGTH scheme scheme_count)
    if(scheme_count GREATER 1)
      ## only one scheme is allowed
      return()
    endif()

    uri_qualify_local_path("${uri}")
    ans(uri)

    uri_format("${uri}" --no-query --remove-scheme hgscm)
    ans(remote_uri)

    ## check if remote exists
    hg_remote_exists("${remote_uri}")
    ans(remote_exists)


    if(NOT remote_exists)
      return()
    endif()

    ## get ref 
    assign(ref = uri.params.ref)
    assign(branch = uri.params.branch)
    assign(tag = uri.params.tag)
    set(ref ${ref} ${branch} ${tag})
    list_pop_front(ref)
    ans(ref)

    if(NOT "${ref}_" STREQUAL "_")
      ## need to checkout

      if("${ref}" STREQUAL "*")
        message(FATAL_ERROR "ref query currently not allowed for hg")
      endif()
      set(result "hgscm+${remote_uri}?ref=${ref}")
    else()
      set(result "hgscm+${remote_uri}")
    endif()

    if(return_package_handle)
      map_new()
      ans(package_handle)
      assign(package_handle.uri = result)
      assign(!package_handle.scm_descriptor.scm = 'hg')
      return_ref(package_handle)
    endif()
    return_ref(result)
  endfunction() 





  ## package_source_pull_managed(<~uri>) -> <package handle>
  ## --reference returns the package with the content still pointing to the original content dir
  function(package_source_pull_managed uri)
    set(args ${ARGN})
    package_source_resolve_managed("${uri}")
    ans(package_handle)
    if(NOT package_handle)
      return()
    endif()

    list_extract_flag(args --reference)
    ans(reference)

    ## remove index field as it is not of interest to the client
    map_remove(${package_handle} index)


    ## if in reference mode copy package_handle content and set new content_dir
    if(NOT reference)
      list_pop_front(args)
      ans(target_dir)
      path_qualify(target_dir)
      
      map_tryget(${package_handle} content_dir)
      ans(source_dir)
      
      cp_dir("${source_dir}" "${target_dir}")
      map_set(${package_handle} content_dir "${target_dir}")
    endif()

    return_ref(package_handle)
  endfunction()







  ## package_source_query_managed(<~uri>) -> <uri string>
  ## 
  ## expects a this object to be defined which contains directory and source_name
  ## 
  function(package_source_query_managed uri)
    this_get(directory)
    this_get(source_name)

    uri("${uri}")
    ans(uri)




    map_tryget(${uri} segments)
    ans(segments)
    list(LENGTH segments segment_length)

    ## if uri has a single segment it is interpreted as a hash
    if(segment_length EQUAL 1 AND IS_DIRECTORY "${directory}/${segments}")
      set(result "${source_name}:${segments}")
    elseif(NOT segment_length EQUAL 0)
      ## multiple segments are not allowed and are a invliad uri
      set(result)
    else()
      ## else parse uri's query (uri starts with ?)

      map_tryget(${uri} query)
      ans(query)
      if("${query}" MATCHES "=")
        ## if query contains an equals it is a map
        ## else it is a value
        map_tryget(${uri} params)
        ans(query)        
      endif()

      ## empty query returns nothing
      if(query STREQUAL "")
        return()
      endif()

      ## read all package indices
      file(GLOB index_files "${directory}/*/index.cmake")

      ## parse index_files
      set(indices)
      foreach(index ${index_files})
        qm_read("${index}")
        ans(package)
        list(APPEND indices "${package}")
      endforeach()


      map_isvalid("${query}")
      ans(ismap)
    
      ## query may be a * which returns all packages 
      ## or a regex /[regex]/
      ## or a map which will uses the properties to match values
      if(query STREQUAL "*")
        list_select_property(indices local_uri)
        ans(result)
      elseif("${query}" MATCHES "^/(.*)/$")
        set(regex "${CMAKE_MATCH_1}")
        set(result)
        foreach(package ${indices})
          map_tryget(${package} hash)
          ans(hash)
          if("${hash}" MATCHES ${regex})
            list(APPEND result "${source_name}:${hash}")
          endif()
        endforeach()
      elseif(ismap)
        ## todo
      endif()

    endif()
    ## return uris
    return_ref(result)
  endfunction()




  ## package_source_push_managed(<package handle> ) -> <uri string>
  ##
  ## returns a valid uri if the package was pushed successfully 
  ## else returns null
  ##
  ## expects a this object to be defined which contains directory and source_name
  ## --reference flag indicates that the content will not be copied into the the package source 
  ##             the already existing package dir will be used 
  ## --force     flag indicates that existing package should be overwritten
  function(package_source_push_managed package_handle)
    set(args ${ARGN})

    list_extract_flag(args --reference)
    ans(reference)

    this_get(directory)
    this_get(source_name)

    ## check if package handle is valid
    package_handle("${package_handle}")
    ans(package_handle)

    if(NOT package_handle)
      return()
    endif()

    ## create a hash for the package
    package_handle_hash("${package_handle}")
    ans(hash)

    set(location "${directory}/${hash}")

    if(EXISTS "${location}")
      ## same hash already used
      return()
    endif()

    map_tryget(${package_handle} content_dir)
    ans(source_content_dir)
    
    set(content_dir "${location}/content")


    ## if reference do not copy content else copy content
    if(NOT reference)
      ## copy only if exists (if it does not exist no content dir is set)
      cp_dir("${source_content_dir}" "${location}/content")
    else()
      set(content_dir "${source_content_dir}")
    endif()

    ## set local urio
    set(local_uri "${source_name}:${hash}")

    set(index)
    
    # create a file contains all searchable data
    assign(!index.hash = hash)
    assign(!index.id = package_handle.package_descriptor.id)
    assign(!index.version = package_handle.package_descriptor.id)
    assign(!index.tags = package_handle.package_descriptor.tags)
    assign(!index.tags[] = package_handle.package_descriptor.id)
    assign(!index.local_uri = local_uri)
    assign(!index.remote_uri = package_handle.uri)
    assign(!index.content_dir = content_dir)
    assign(!index.source_content_dir = source_content_dir)
    assign(package_descriptor = package_handle.package_descriptor)

    qm_write("${location}/package.cmake" "${package_descriptor}")
    qm_write("${location}/index.cmake" "${index}")

    return_ref(local_uri)
  endfunction()










  function(managed_package_source source_name directory)
    path_qualify(directory)
    obj("{
      source_name:$source_name,
      directory:$directory,
      pull:'package_source_pull_managed',
      push:'package_source_push_managed',
      query:'package_source_query_managed',
      resolve:'package_source_resolve_managed'
    }")
    return_ans()
  endfunction()





  ## package_handle_hash(<~package handle>) -> <string>
  ## creates a hash for an installed package the hash should be unique enough and readable enough
  function(package_handle_hash package_handle)
    package_handle("${package_handle}")
    ans(package_handle)

    assign(id = package_handle.package_descriptor.id)
    assign(version = package_handle.package_descriptor.version)

    set(hash "${id}_${version}")
    string(REPLACE "." "_" hash "${hash}")
    string(REPLACE "/" "_" hash "${hash}")
    return_ref(hash)
  endfunction()





  ## package_source_resolve_managed(<~uri>) -> <package_handle>
  ##
  ## expects a var called this exist which contains the properties 'directory' and 'source_name'
  ## 
  function(package_source_resolve_managed uri)
    ## query for package uri
    package_source_query_managed("${uri}")
    ans(valid_uri_string)


    list(LENGTH valid_uri_string count)
    if(NOT count EQUAL 1)
      return()
    endif()

    ## if uri contains query return
    if("${uri}" MATCHES "\\?")
      return()
    endif()


    this_get(directory)

    ## parse uri
    uri("${valid_uri_string}")
    ans(uri)

    ## the scheme specific part is the hash (ie everything but the scheme)
    map_tryget(${uri} scheme_specific_part)
    ans(hash)

    set(managed_dir "${directory}/${hash}")

    ## read the index file in the correct folder (hash)
    ## if none exists then the uri is invalid
    qm_read("${managed_dir}/index.cmake")
    ans(index)

    if(NOT index)
      return()
    endif()

    ## read the package descriptor which is stored alongside the index
    qm_read("${managed_dir}/package.cmake")
    ans(package_descriptor)
    if(NOT package_descriptor)
      return()
    endif()

    ## get content dir from index (might not be a subdir if push --reference is used)
    map_tryget(${index} content_dir)
    ans(content_dir)

    ## generate response
    map_new()
    ans(response)
    map_set(${response} package_descriptor "${package_descriptor}")
    map_set(${response} uri "${valid_uri_string}")
    map_set(${response} content_dir "${content_dir}")
    map_set(${response} managed_dir "${managed_dir}")
    map_set(${response} index "${index}") ## also store the optional index 
    return_ref(response)
  endfunction()




## query_package(<~uri> [--package-handle]) -> <uri string>|<package handle>
## queries the default package source for a package
function(query_package)
  default_package_source()
  ans(source)
  call(source.query(${ARGN}))
  return_ans()
endfunction()





  ## package_source_pull_composite(<~uri?>) -> <package handle>
  ##
  ## pulls the specified package from the best matching child sources
  ## returns the corresponding handle on success else nothing is returned
  function(package_source_pull_composite uri)
    set(args ${ARGN})

    uri("${uri}")
    ans(uri)

    ## resolve package and return if none was found
    package_source_resolve_composite("${uri}")
    ans(package_handle)

    if(NOT package_handle)
      return()
    endif()

    ## get package source and uri from handle
    ## because current uri might not be fully qualified
    map_tryget(${package_handle} package_source)
    ans(package_source)

    map_tryget(${package_handle} uri)
    ans(package_uri)

    ## use the package package source to pull the correct package
    ## and return the result
    call(package_source.pull("${package_uri}" ${args}))
    ans(package_handle)

    return_ref(package_handle)
  endfunction()





## package_source_query_composite(<~uri> [--package-handle]) -> <uri..>|<pacakage handle...>
##
## --package-handle  flag specifiec that not a uri but a <package handle> should be returned
##
## queries the child sources (this.children) for the specified uri
## this is done by first rating and sorting the sources depending on 
## the uri so the best source is queryied first
## if a source returns a rating of 999 all other sources are disregarded
  function(package_source_query_composite uri)
    uri("${uri}")
    ans(uri)

    set(args ${ARGN})

    list_extract_flag(args --package-handle)
    ans(package_handle)

    ## rate and sort sources for uri    
    this_get(children)
    rated_package_source_sort("${uri}" ${children})
    ans(rated_children)

    ## loop through every source and query it for uri
    ## append results to result. 
    ## if the rating is 0 break because all following sources will
    ## also be 0 and this indicates that the source is incompatible 
    ## with the uri
    ## if the rating is 999 break after querying the source as this 
    ## source has indicated that it is solely responsible for this uri
    set(result)
    while(true)
      if(NOT rated_children)
        break()
      endif()

      list_pop_front(rated_children)
      ans(current)

      map_tryget(${current} rating)
      ans(rating)

      ## source and all rest sources are incompatible 
      if(rating EQUAL 0)
        break()
      endif()

      map_tryget(${current} source)
      ans(source)

      ## query the source
      rcall(current_result = source.query("${uri}" ${args}))


      ## if package_handles should be returned 
      ## create the objects and replace current result with it
      if(package_handle)
        set(package_handles)
        foreach(uri ${current_result})
          map_new()
          ans(package_handle)
          map_set(${package_handle} uri ${uri})
          map_set(${package_handle} package_source ${source})
          map_set(${package_handle} rating ${rating})
          list(APPEND package_handles ${package_handle})
        endforeach()
        set(current_result ${package_handles})
      endif()

      ## append to result
      list(APPEND result ${current_result})

      ## source has indicated it is solely responsible for uri
      ## all further sources are disregarded
      if(NOT rating LESS  999)
        break()
      endif()
    endwhile()

    return_ref(result)
  endfunction()
  

  ## creates rated package sources from the specified sources
  ## { rating:<number>, source:<package source>}
  function(rated_package_sources)
    set(result)
    foreach(source ${ARGN})
      map_new() 
      ans(map)
      map_set(${map} source ${source})
      package_source_rate_uri(${source} ${uri})
      ans(rating)
      map_set(${map} rating ${rating}) 
      list(APPEND result ${map})
    endforeach()
    return_ref(result)
  endfunction()

  ## sorts the rated package sources by rating
  ## and returns them
  function(rated_package_source_sort uri)
    rated_package_sources(${ARGN})
    ans(rated_sources)


    list_sort(rated_sources rated_package_source_compare)
    ans(rated_sources)
    return_ref(rated_sources)
  endfunction()

  ## compares two rated package sources and returns a number
  ## pointing to the lower side
  function(rated_package_source_compare lhs rhs)
      map_tryget(${rhs} rating)
      ans(rhs)
      map_tryget(${lhs} rating)
      ans(lhs)
      math(EXPR result "${lhs} - ${rhs}")
      return_ref(result)
  endfunction()

  ## function used to rate a package source and a a uri
  ## default rating is 1 
  ## if a scheme of uri matches the source_name property
  ## of a package source the rating is 999
  ## else package_source's rate_uri function is called
  ## if it exists which can return a custom rating
  function(package_source_rate_uri package_source uri)
    uri("${uri}")
    ans(uri)

    set(rating 1)

    map_tryget(${uri} schemes)
    ans(schemes)
    map_tryget(${package_source} source_name)
    ans(source_name)

    ## contains scheme -> rating 999
    list_contains(schemes "${source_name}")
    ans(contains_scheme)

    if(contains_scheme)
      set(rating 999)
    endif()

    ## package source may override default behaviour
    map_tryget(${package_source} rate_uri)
    ans(rate_uri)
    if(rate_uri)
      call(source.rate_uri(${uri}))
      ans(rating)
    endif()

    return_ref(rating)
  endfunction()




## adds a package soruce to the composite package soruce
function(composite_package_source_add source)
  assign(this.children[] = source)
  return()
endfunction()




  ## package_source_resolve_composite(<~uri>) -> <package handle>
  ## returns the package handle for the speciified uri
  ## the handle's package_source property will point to the package source used

  function(package_source_resolve_composite uri)
    set(args ${ARGN})

    uri("${uri}")
    ans(uri)

    ## query composite returns the best matching package_uris first
    ## specifiying --package-handle returns the package handle as 
    ## containing the package_uri and the package_source
    package_source_query_composite("${uri}" --package-handle)
    ans(package_handles)

    ## loops through every package handle and tries to resolve
    ## it. returns the handle on the first success
    while(true)

      if(NOT package_handles)
        return()
      endif()

      list_pop_front(package_handles)
      ans(package_handle)
      
      map_tryget(${package_handle} package_source)
      ans(package_source)
      map_tryget(${package_handle} uri)
      ans(uri)

      rcall(package_handle = package_source.resolve("${uri}"))

      if(package_handle)
        ## copy over package source to new package handle
        assign(package_handle.package_source = package_source)
       # assign(package_handle.rating = source_uri.rating)
        return_ref(package_handle)
      endif()

    endwhile()
    return()
  endfunction() 

  





  function(composite_package_source source_name)
    set(sources ${ARGN})
    obj("{
      source_name:$source_name,
      children:$sources,
      query:'package_source_query_composite',
      resolve:'package_source_resolve_composite',
      pull:'package_source_pull_composite',
      add:'composite_package_source_add'
    }")
    return_ans()
  endfunction()





  ## package_source_pull_directory(<~uri> [--reference]) -> <package handle>
  ## --reference flag 
  function(package_source_pull_directory uri)
    set(args ${ARGN})

    package_source_resolve_directory("${uri}")
    ans(package_handle)

    if(NOT package_handle)
      return()
    endif()

    list_extract_flag(args --reference)
    ans(reference)

    if(NOT reference)
      list_pop_front(args)
      ans(target_dir)
      path_qualify(target_dir)
    
      map_tryget(${package_handle} content_dir)
      ans(source_dir)

      cp_dir("${source_dir}" "${target_dir}")
      map_set(${package_handle} content_dir "${target_dir}")  
    endif()
    
    return_ref(package_handle)
  endfunction()





## package_source_resolve_directory(<~uri>) -> <package handle>
  function(package_source_resolve_directory uri)
    uri("${uri}")
    ans(uri)

    package_source_query_directory("${uri}")
    ans(valid_uri_string)

    list(LENGTH valid_uri_string count)
    if(NOT count EQUAL 1)
      return()
    endif()

    ## if uri contains query return
    map_tryget(${uri} query)
    ans(query)
    if(NOT "${query}_" STREQUAL "_")
      return()
    endif()

    this_get(directory)

    ## parse uri
    uri("${valid_uri_string}")
    ans(uri)

    map_tryget(${uri} scheme_specific_part)
    ans(subdir)

    set(content_dir "${directory}/${subdir}")

    package_handle("${content_dir}")
    ans(package_handle)

    map_tryget("${package_handle}" package_descriptor)
    ans(package_descriptor)

    map_defaults("${package_descriptor}" "{
      id:$subdir,
      version:'0.0.0'
    }")
    ans(package_descriptor)

    ## response
    map_new()
    ans(package_handle)
    map_set(${package_handle} package_descriptor "${package_descriptor}")
    map_set(${package_handle} uri "${valid_uri_string}")
    map_set(${package_handle} content_dir "${content_dir}")

    return_ref(package_handle)
  endfunction()





  ## package_source_query_directory(<~uri>) -> <uri string>
  function(package_source_query_directory uri)
    this_get(directory)
    this_get(source_name)

    uri("${uri}")
    ans(uri)

    ## return if scheme is either empty or equal to source_name
    map_tryget(${uri} scheme)
    ans(scheme)

      
    if(NOT "${scheme}_" STREQUAL "_" AND NOT "${scheme}_" STREQUAL "${source_name}_")
      return()
    endif()

    map_tryget(${uri} segments)
    ans(segments)
    list(LENGTH segments segment_length)

    ## if uri has a single segment it is interpreted as a hash
    if(segment_length EQUAL 1 AND IS_DIRECTORY "${directory}/${segments}")
      set(result "${source_name}:${segments}")
    elseif(NOT segment_length EQUAL 0)
      ## multiple segments are not allowed and are a invliad uri
      set(result)
    else()
      ## else parse uri's query (uri starts with ?)

      map_tryget(${uri} query)
      ans(query)
      if("${query}" MATCHES "=")
        ## if query contains an equals it is a map
        ## else it is a value
        map_tryget(${uri} params)
        ans(query)        
      endif()

      ## empty query returns nothing
      if(query STREQUAL "")
        return()
      endif()

      ## read all package indices
      file(GLOB folders RELATIVE "${directory}" "${directory}/*")

      map_isvalid("${query}")
      ans(ismap)
    
      ## query may be a * which returns all packages 
      ## or a regex /[regex]/
      ## or a map which will uses the properties to match values
      if(query STREQUAL "*")
        set(result)
        foreach(folder ${folders})
          list(APPEND result "${source_name}:${folder}")
        endforeach()
      elseif("${query}" MATCHES "^/(.*)/$")
        ## todo
        set(result)
      elseif(ismap)
        ## todo
        set(result)
      endif()
    endif()


    return_ref(result)

  endfunction()







  function(directory_package_source source_name directory)
    path_qualify(directory)
    obj("{
      source_name:$source_name,
      directory:$directory,
      pull:'package_source_pull_directory',
      query:'package_source_query_directory',
      resolve:'package_source_resolve_directory'
    }")
    return_ans()
  endfunction()





## package_source_pull(<~uri> <?target_dir:<path>>) -> <package handle>
##
## pulls the content of package specified by uri into the target_dir 
## if the package_descriptor contains a content property it will interpreted
## as a glob/ignore expression list when copy files (see cp_content(...)) 
##
## --reference flag indicates that nothing is to be copied but the source 
##             directory will be used as content dir 
##
## 
function(package_source_pull_path uri)
    set(args ${ARGN})


    ## get package descriptor for requested uri
    package_source_resolve_path("${uri}")
    ans(package_handle)

    if(NOT package_handle)
      return()
    endif()


    map_tryget(${package_handle} package_descriptor)
    ans(package_descriptor)

    list_extract_flag(args --reference)
    ans(reference)

    if(NOT reference)
        ## get and qualify target path
        list_pop_front(args)
        ans(target_dir)
        path_qualify(target_dir)

        ## get local_ref which is were the package is stored locally in a path package source
        map_tryget("${package_handle}" "content_dir")
        ans(source_dir)

        ## copy content to target dir
        map_tryget("${package_descriptor}" content)
        ans(content_globbing_expression)
        cp_content("${source_dir}" "${target_dir}" ${content_globbing_expression})

        ## replace content_dir with the new target path and return  package_handle
        map_set("${package_handle}" content_dir "${target_dir}")
    endif()

    return_ref(package_handle)
endfunction()




## package_source_query_path(<uri> <?target_path>)
function(package_source_query_path uri)
  uri("${uri}")
  ans(uri)


  ## check that uri is local
  map_tryget("${uri}" "normalized_host")
  ans(host)

  if(NOT "${host}" STREQUAL "localhost")
    return()
  endif()   

  ## get localpath from uri and check that it is a dir and cotnains a package_descriptor
  uri_to_localpath("${uri}")
  ans(path)

  path("${path}")
  ans(path)

  if(NOT IS_DIRECTORY "${path}")
    return()
  endif()

  ## create the valid result uri (file:///e/t/c)
  uri("${path}")
  ans(result)

  ## convert uri to string
  uri_format("${result}")
  ans(uri_string)

return_ref(uri_string)
endfunction()





  function(path_package_source)
    obj("{
      source_name:'file',
      pull:'package_source_pull_path',
      query:'package_source_query_path',
      resolve:'package_source_resolve_path'
    }")
    return_ans()
  endfunction()





## returns a pacakge descriptor if the uri identifies a unique package
function(package_source_resolve_path uri)
    ## get valid uris by querying ensure that only a single uri is found
    package_source_query_path("${uri}")
    ans(valid_uri_string)

    list(LENGTH valid_uri_string package_count)
    if(NOT "${package_count}" EQUAL 1)
      return()
    endif()

    ## generate uri object and get local path
    uri("${valid_uri_string}")
    ans(valid_uri)

    uri_to_localpath("${valid_uri}")
    ans(path)

    ## read package descriptor and set default values
    package_handle("${path}")
    ans(package_handle)

    map_tryget("${package_handle}" package_descriptor)
    ans(package_descriptor)

    map_tryget(${valid_uri} last_segment)
    ans(default_id)

    map_defaults("${package_descriptor}" "{id:$default_id,version:'0.0.0'}")
    ans(package_descriptor)

    ## response
    map_new()
    ans(package_handle)
    map_set(${package_handle} package_descriptor "${package_descriptor}")
    map_set(${package_handle} content_dir "${path}")
    map_set(${package_handle} uri "${valid_uri_string}")

    return(${package_handle})
endfunction()





## package_source_push_path(<installed package> <~uri> <package_content_copy_args:<args...>?>)
  function(package_source_push_path package_handle uri)
    set(args ${ARGN})
    
    ## resolve installed package
    package_handle("${package_handle}")
    ans(package_handle)

    if(NOT package_handle)
      return()
    endif()

    ## get package_descriptor and source_dir from package_handle
    map_tryget(${package_handle} package_descriptor)
    ans(package_descriptor)

    map_tryget(${package_handle} content_dir)
    ans(source_dir)

    ## get target_dir
    uri("${uri}")
    ans(uri)

    uri_to_localpath("${uri}")
    ans(target_dir)

    path_qualify(target_dir)
    

    ## copy content to target dir
    map_tryget("${package_descriptor}" content)
    ans(content_globbing_expression)
    cp_content("${source_dir}" "${target_dir}" ${content_globbing_expression})
    ans(result)


    ## return the valid target uri
    uri("${target_dir}")
    ans(target_uri)

    uri_format(${target_uri})
    ans(target_uri)

    return_ref(target_uri)
  endfunction()





  function(webarchive_package_source)
    obj("{
      source_name:'webarchive',
      pull:'package_source_pull_webarchive',
      query:'package_source_query_webarchive',
      resolve:'package_source_resolve_webarchive'
    }")
    return_ans()
  endfunction()





  function(package_source_pull_webarchive uri)
    set(args ${ARGN})

    list_extract_flag_name(args --refresh)
    ans(refresh)

    list_pop_front(args)
    ans(target_dir)
    path_qualify(target_dir)

    package_source_query_webarchive("${uri}" ${refresh})
    ans(package_uri)
    list(LENGTH package_uri uri_count)
    if(NOT uri_count EQUAL 1)
      return()
    endif()

    download_cached("${package_uri}" "${target_dir}" --readonly)
    ans(archive_path)

    package_source_pull_archive("${archive_path}" "${target_dir}")
    ans(package)

    map_set(${package} uri "${package_uri}")
    map_set(${package} content_dir "${target_dir}")

    return_ref(package)
  endfunction()






## package_source_query_webarchive(<~uri> <args...>) -> <package uri...>
##
## if uri identifies a package the <package uri> is returned - else nothing is returned  
##
## queries the specified uri for a remote <archive> uses `download_cached` to
## download it. (else it would have to be downloaded multiple times)
##
##   
function(package_source_query_webarchive uri)
  set(args ${ARGN})

  ## parse and format uri
  uri("${uri}")
  ans(uri)

  uri_format("${uri}")
  ans(uri_string)

  ## use download cached to download a package (pass along vars like)
  download_cached("${uri_string}" --readonly ${args})
  ans(path)

  ## check if file is an archive
  archive_isvalid("${path}")
  ans(is_archive)

  if(NOT is_archive)
    return()
  endif()

  return("${uri_string}")

endfunction()







  function(package_source_resolve_webarchive uri)
    set(args ${ARGN})
    package_source_query_webarchive("${uri}" ${args})
    ans(valid_uri_string)
    list(LENGTH valid_uri_string uri_count)
    if(NOT uri_count EQUAL 1)
      return()
    endif()

    download_cached("${valid_uri_string}" --readonly)
    ans(cached_archive_path)

    package_source_resolve_archive("${cached_archive_path}")
    ans(result)


    map_set(${result} uri "${valid_uri_string}")
    map_remove(${result} content_dir)

    return(${result})
  endfunction()








## resolve_package(<~uri>) -> <package handle>
## 
function(resolve_package)
  default_package_source()
  ans(source)
  call(source.resolve(${ARGN}))
  return_ans()
endfunction()







  ## 
  function(package_source_query_archive uri_string)
    uri("${uri_string}")
    ans(uri)

    ## uri needs to be local
    map_tryget(${uri} normalized_host)
    ans(host)
    if(NOT host STREQUAL "localhost")
      return()
    endif()

    ## get the local_path of the uri
    uri_to_localpath("${uri}")
    ans(local_path)

    path_qualify(local_path)

    ## check that file exists and is actually a archive
    archive_isvalid("${local_path}")
    ans(is_archive)

    if(NOT is_archive)
      return()
    endif()

    ## qualify uri to absolute path
    uri_qualify_local_path("${uri}")
    uri_format("${uri}")
    ans(package_uri)

    return_ref(package_uri)
  endfunction()








  function(package_source_push_archive package_handle uri)
    set(args ${ARGN})

    ## parse and extract package_descriptor and package dir
    package_handle("${package_handle}")
    ans(package_handle)

    if(NOT package_handle)
      return()
    endif()

    map_tryget("${package_handle}" package_descriptor)
    ans(package_descriptor)

    map_tryget("${package_handle}" content_dir)
    ans(source_dir)


    uri("${uri}")
    ans(uri)

    ## get fully qualified local path
    uri_to_localpath("${uri}")
    ans(archive_path)
    path_qualify(archive_path)

    ## copy package content to a temporary directory
    file_tempdir()
    ans(temp_dir)

    package_source_push_path("${source_dir};${package_descriptor}" "${temp_dir}" --force)


    ## pass format along
    list_extract_labelled_keyvalue(args --format)
    ans(format)

    ## compress all files in temp_dir into package
    pushd("${temp_dir}")
      compress("${archive_path}" "**" ${format})
    popd()

    ## delete temp dir
    rm("${temp_dir}")

    ## return valid package uri
    uri_format("${archive_path}")
    ans(result)

    return_ref(result)
  endfunction()





function(package_source_resolve_archive uri)
    ## query for uri and return if no single uri is found
    package_source_query_archive("${uri}")
    ans(valid_uri)

    list(LENGTH valid_uri uri_count)
    if(NOT uri_count EQUAL 1)
      return()
    endif()


    uri("${valid_uri}")
    ans(uri)

    ## read the package_descriptor file from the archive
    ## if it exists
    uri_to_localpath("${uri}")
    ans(archive_path)

    file_tempdir()
    ans(temp_dir)

    uncompress_file("${temp_dir}" "${archive_path}" "package.cmake")
    package_handle("${temp_dir}")
    ans(package_handle)
    rm("${temp_dir}")

    map_tryget("${package_handle}" package_descriptor)
    ans(package_descriptor)

    ## get default values for package_descriptor by parsing
    ## the file name
    map_tryget(${uri} file_name)
    ans(file_name)

    package_descriptor_parse_filename("${file_name}")
    ans(defaults)

    map_defaults("${package_descriptor}" "${defaults}")
    ans(package_descriptor)

    ## response 
    map_new()
    ans(result)
    map_set(${result} package_descriptor "${package_descriptor}")    
    map_set(${result} uri "${valid_uri}")    

    return_ref(result)
endfunction()






  function(package_source_pull_archive uri)
    set(args ${ARGN})

    ## get package from uri

    package_source_resolve_archive("${uri}")
    ans(package)

    if(NOT package)
      return()
    endif()

    ## get valid uri from package
    map_tryget(${package} uri)
    ans(uri)

    uri_to_localpath("${uri}")
    ans(archive_path)

    list_pop_front(args)
    ans(target_dir)


    ## uncompress compressed file to target_dir
    pushd("${target_dir}" --create)
      ans(target_dir)
      uncompress("${archive_path}")
    popd()

    ## set content_dir
    map_set(${package} content_dir "${target_dir}")


    return_ref(package)
  endfunction()







  function(archive_package_source)
    obj("{
      source_name:'archive',
      pull:'package_source_pull_archive',
      query:'package_source_query_archive',
      resolve:'package_source_resolve_archive'
    }")
    return_ans()
  endfunction()






  ## parses the package descriptor from the filename
  ## a filename's version is separated by a hyphen
  function(package_descriptor_parse_filename file_name)
    string_take_regex(file_name "([^-]|(-[^0-9]))+")
    ans(default_id)
    set(rest "${file_name}")
    string_take_regex(file_name "\\-")
    string_take_regex(file_name "v")

    semver_format("${file_name}")
    ans(default_version)
    if(default_version STREQUAL "")
      set(default_version "0.0.0")
    endif()

    data("{id:$default_id, version:$default_version}")
    return_ans()
  endfunction()




# removes the last element from list and returns it
function(list_pop_back __list_pop_back_lst)

  if("${${__list_pop_back_lst}}_" STREQUAL "_")
    return()
  endif()
  list(LENGTH "${__list_pop_back_lst}" len)
  math(EXPR len "${len} - 1")
  list(GET "${__list_pop_back_lst}" "${len}" res)
  list(REMOVE_AT "${__list_pop_back_lst}" ${len})
  set("${__list_pop_back_lst}" ${${__list_pop_back_lst}} PARENT_SCOPE)
  return_ref(res)
endfunction()



  # removes the last element from list and returns it
  ## faster version
macro(list_pop_back __list_pop_back_lst)
  if("${${__list_pop_back_lst}}_" STREQUAL "_")
    set(__ans)
  else()
    list(LENGTH "${__list_pop_back_lst}" __list_pop_back_length)
    math(EXPR __list_pop_back_length "${__list_pop_back_length} - 1")
    list(GET "${__list_pop_back_lst}" "${__list_pop_back_length}" __ans)
    list(REMOVE_AT "${__list_pop_back_lst}" ${__list_pop_back_length})
  endif()
endmacro()




# retruns a portion of the list specified.
# negative indices count from back of list 
#
function(list_slice __list_slice_lst start_index end_index)
  # indices equal => select nothing

  list_normalize_index(${__list_slice_lst} ${start_index})
  ans(start_index)
  list_normalize_index(${__list_slice_lst} ${end_index})
  ans(end_index)

  if(${start_index} LESS 0)
    message(FATAL_ERROR "list_slice: invalid start_index ")
  endif()
  if(${end_index} LESS 0)
    message(FATAL_ERROR "list_slice: invalid end_index")
  endif()
  # copy array
  set(res)
  index_range(${start_index} ${end_index})
  ans(indices)

  list(LENGTH indices indices_len)
  if(indices_len)
    list(GET ${__list_slice_lst} ${indices} res)
  endif()
  #foreach(idx ${indices})
   # list(GET ${__list_slice_lst} ${idx} value)
    #list(APPEND res ${value})
   # message("getting value at ${idx} from ${${__list_slice_lst}} : ${value}")
  #endforeach()
 # message("${start_index} - ${end_index} : ${indices} : ${res}" )
  return_ref(res)
endfunction()








    ## extracts a labelled key value (the label and the value if it exists)
    macro(list_extract_labelled_keyvalue __lst label)
      list_extract_labelled_value(${__lst} "${label}")
      ans(__lbl_value)
      if(NOT "${__lbl_value}_" STREQUAL "_")
        set_ans("${label};${__lbl_value}")
      else()
        set_ans("")
      endif()
    endmacro()




# removes the specified range from lst the start_index is inclusive and end_index is exclusive
#
macro(list_erase __list_erase_lst start_index end_index)
  list_without_range(${__list_erase_lst} ${start_index} ${end_index})
  ans(${__list_erase_lst})

endmacro()




# adds a value to the end of the list
function(list_push_back __list_push_back_lst value)
  set(${__list_push_back_lst} ${${__list_push_back_lst}} ${value} PARENT_SCOPE)
endfunction()





# extracts all flags specified and returns a map with the key being the flag name if it was found and the value being set to tru
# e.g. list_extract_flags([a,b,c,d] a c e) -> {a:true,c:true}, [b,d]
function(list_extract_flags __list_extract_flags_lst)
  list_find_flags("${__list_extract_flags_lst}" ${ARGN})
  ans(__list_extract_flags_flag_map)
  map_keys(${__list_extract_flags_flag_map})
  ans(__list_extract_flags_found_flags)
  list(REMOVE_ITEM "${__list_extract_flags_lst}" ${__list_extract_flags_found_flags})
  set("${__list_extract_flags_lst}" ${${__list_extract_flags_lst}} PARENT_SCOPE)
  return(${__list_extract_flags_flag_map})
endfunction()





# adds a value at the beginning of the list
function(list_push_front __list_push_front_lst value)
  set(${__list_push_front_lst} ${value} ${${__list_push_front_lst}} PARENT_SCOPE)   
  return(true)
endfunction()




# returns true if __list_contains_lst contains every element of ARGN 
function(list_contains __list_contains_lst)
	foreach(arg ${ARGN})
		list(FIND ${__list_contains_lst} "${arg}" idx)
		if(${idx} LESS 0)
			return(false)
		endif()
	endforeach()
	return(true)
endfunction()






  ## returns all elements whose index are specfied in that order
  ## 
  function(list_at __list_at_lst)
    set(__list_at_result)
    foreach(__list_at_idx ${ARGN})
      list_get(${__list_at_lst} ${__list_at_idx})
      list(APPEND __list_at_result ${__ans})
    endforeach()
    return_ref(__list_at_result)
  endfunction()




# comapres two lists with each other
# usage
# list_equal( 1 2 3 4 1 2 3 4)
# list_equal( listA listB)
# list_equal( ${listA} ${listB})
# ...
# COMPARATOR defaults to STREQUAL
# COMPARATOR can also be a lambda expression
# COMPARATOR can also be EQUAL
function(list_equal)
	set(options)
  	set(oneValueArgs COMPARATOR)
  	set(multiValueArgs)
  	set(prefix)
  	cmake_parse_arguments("${prefix}" "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
	#_UNPARSED_ARGUMENTS


	# get length of both lists

	list(LENGTH _UNPARSED_ARGUMENTS count)



	#if count is exactly two input could be list references
	if(${count} EQUAL 2)
		list(GET _UNPARSED_ARGUMENTS 0 ____listA)
		list(GET _UNPARSED_ARGUMENTS 1 ____listB)
		if(DEFINED ${____listA} AND DEFINED ${____listB})
			# recursive call and return
			list_equal(  ${${____listA}} ${${____listB}} COMPARATOR "${_COMPARATOR}")
			return_ans()
		endif()

	endif()

	set(listA)
	set(listB)




	math(EXPR single_count "${count} / 2")
	math(EXPR is_even "${count} % 2")
	if(NOT ${is_even} EQUAL "0")
		#element count is not divisible by two so the lists cannot be equal
		# because they do not have the same length

		return(false)

	else()
		# split input arguments into two
		list_split(listA listB _UNPARSED_ARGUMENTS ${single_count})
	#message("${_UNPARSED_ARGUMENTS} => ${listA} AND ${listB}")
	endif()


	# set default comparator to strequal
	if(NOT _COMPARATOR)
		set(_COMPARATOR "STREQUAL")
	endif()

	# depending on the comparator
	if(${_COMPARATOR} STREQUAL "STREQUAL")
		set(lambda "(a b) eval_truth(\"\${a}\" STREQUAL \"\${b}\") \n ans(res) \n return_value(\${res})")
	elseif(${_COMPARATOR} STREQUAL "EQUAL")
		set(lambda "(a b) eval_truth( \"\${a}\" EQUAL \"\${b}\") \n ans(res) \n return_value(\${res})")
	else()
		set(lambda "${_COMPARATOR}")
	endif()

	# convert lambda expressin into a  function string
	lambda(lambda "${lambda}")

	# import function string 
	function_import("${lambda}" as __list_equal_comparator REDEFINE)
		
	set(res)
	# compare list
	math(EXPR single_count "${single_count} - 1")
	foreach(i RANGE ${single_count})
		list(GET listA ${i} a)
		list(GET listB ${i} b)
		#message("comparing ${a} ${b}")
		__list_equal_comparator(res ${a} ${b})
		if(NOT res)
			return(false)
		endif()
	endforeach()
	return(true)

endfunction()




# returns a list containing all elemmtns contained
# in all passed list references
function(list_intersect)
  set(__list_intersect_lists ${ARGN})

  list(LENGTH __list_intersect_lists __list_intersect_lists_length)
  if(NOT __list_intersect_lists_length)
    return()
  endif()

  if("${__list_intersect_lists_length}" EQUAL 1)
    if("${__list_intersect_lists}")
      list(REMOVE_DUPLICATES "${__list_intersect_lists}")
    endif()
    return_ref("${__list_intersect_lists}")
  endif()


  list_pop_front(__list_intersect_lists)
  ans(__list_intersect_first)
  list_intersect(${__list_intersect_first})
  ans(__list_intersect_current_elements)
  # __list_intersect_current_elements is now unique

  # intersect rest elements
  list_intersect(${__list_intersect_lists})
  ans(__list_intersect_rest_elements)

  # get elements which are to be removed from list
  set(__list_intersect_elements_to_remove ${__list_intersect_current_elements})
  if(__list_intersect_elements_to_remove)
    foreach(__list_operation_item ${__list_intersect_rest_elements})
      list(REMOVE_ITEM __list_intersect_elements_to_remove ${__list_operation_item})
    endforeach()  
  endif()
  # remove elements and return result
  if(__list_intersect_elements_to_remove)
    list(REMOVE_ITEM __list_intersect_current_elements ${__list_intersect_elements_to_remove})
  endif()
  return_ref(__list_intersect_current_elements)
endfunction()




# searchs for label in lst. if label is found 
# the label and its following value is removed
# and returned
# if label is found but no value follows ${ARGN} is returned
# if following value is enclosed in [] the brackets are removed
# this allows mulitple values to be returned ie
# list_extract_labelled_value(lstA --test1)
# if lstA is a;b;c;--test1;[1;3;4];d
# the function returns 1;3;4
function(list_extract_labelled_value lst label)
  # return nothing if lst is empty
  list_length(${lst})
  ans(len)
  if(NOT len)
    return()
  endif()
  # find label in list
  list_find(${lst} "${label}")
  ans(pos)
  
  if("${pos}" LESS 0)
    return()
  endif()

  eval_math("${pos} + 2")
  ans(end)


  if(${end} GREATER ${len} )
    eval_math("${pos} + 1")
    ans(end)
  endif()

  list_erase_slice(${lst} ${pos} ${end})
  ans(vals)
  list_pop_front(vals)
  ans(flag)
    
  # special treatment for [] values
  if("_${vals}" MATCHES "^_\\[.*\\]$")
    string_slice("${vals}" 1 -2)
    ans(vals)
  endif()

  if(NOT vals)
    set(vals ${ARGN})
  endif()

  
  set(${lst} ${${lst}} PARENT_SCOPE)


  return_ref(vals)
endfunction()





## counts all element for which the element hold 
function(list_count __list_count_lst __list_count_predicate)
  function_import("${__list_count_predicate}" as __list_count_predicate REDEFINE)
  set(__list_count_counter 0)
  foreach(__list_count_item ${${__list_count_lst}})
    __list_count_predicate("${__list_count_item}")
    ans(__list_count_match)
    if(__list_count_match)
      math(EXPR __list_count_counter "${__list_count_counter} + 1") 
    endif()
  endforeach()
  return("${__list_count_counter}")
endfunction()




## Returns the last element of a list without modifying it
function(list_peek_back  __list_peek_back_lst)
  if("${${__list_peek_back_lst}}_" STREQUAL "_")
    return()
  endif()
  list(LENGTH ${__list_peek_back_lst} len)
  math(EXPR len "${len} - 1")
  list(GET ${__list_peek_back_lst} "${len}" res)
  return_ref(res)
endfunction()






# removes the specified range from lst and returns the removed elements
macro(list_erase_slice __list_erase_slice_lst start_index end_index)
  list_slice(${__list_erase_slice_lst} ${start_index} ${end_index})
  ans(__res)

  list_without_range(${__list_erase_slice_lst} ${start_index} ${end_index})
  ans(${__list_erase_slice_lst})
  set(__ans ${__res})
  #set(${__list_erase_slice_lst} ${rest} PARENT_SCOPE)
  #return_ref(res)
endmacro()








# extracts elements from the list
# example
# set(lst 1 2  )
# list_extract(lst a b c)
# a contains 1
# b contains 2
# c contains nothing
# returns the rest of list
function(list_extract __list_extract_lst)
  set(__list_extract_list_tmp ${${__list_extract_lst}})
  set(args ${ARGN})
  while(true)
    list_pop_front( __list_extract_list_tmp)
    ans(current_value)
    list_pop_front( args)
    ans(current_arg)
    if(NOT current_arg)
      return()
    endif()
    set(${current_arg} ${current_value} PARENT_SCOPE)
  endwhile()
  return_ref(__list_extract_list_tmp)
endfunction()










  ## list_before(<list ref> <key:<string>>)-><any ....>
  ##
  ## returns the elements after the before key
  function(list_before __lst __key)
    list(LENGTH ${__lst} __len)
    if(NOT __len)
      return()
    endif()
    list(FIND ${__lst} "${__key}" __idx)
    if(__idx LESS 0)
      return()
    endif()
    math(EXPR __idx "${__idx} + 1")
    list_split(__lhs __ ${__lst} ${__idx})
    return_ref(__lhs)
  endfunction()





## returns the item at the specified index
## the index is normalized (see list_normalize_index)
function(list_get __list_get_lst idx)
  list_normalize_index("${__list_get_lst}" "${idx}")
  ans(index)
  list_length("${__list_get_lst}")
  ans(len)
  if("${index}" LESS 0 OR "${index}" GREATER "${len}")
    return()
  endif()
  list(GET ${__list_get_lst} "${index}" value)
  return_ref(value)
endfunction()





## instanciates a list_iterator from the specified list
  function(list_iterator __list_ref)
    list(LENGTH ${__list_ref} __list_ref_len)
    return(${__list_ref} ${__list_ref_len} 0-1)
  endfunction()





 ## extracts a flag from the list if it is found 
 ## returns the flag itself (usefull for forwarding flags)
  macro(list_extract_flag_name __lst __flag)
    list_extract_flag("${__lst}" "${__flag}")
    ans(__flag_was_found)
    set_ans("")
    if(__flag_was_found)
      set_ans("${__flag}")
    endif()
  endmacro()





  ## replaces the specified slice with the specified varargs
  ## returns the elements which were removed
  function(list_replace_slice __list_ref __start_index __end_index)
    ## normalize indices
    list_normalize_index(${__list_ref} ${__start_index})
    ans(__start_index)
    list_normalize_index(${__list_ref} ${__end_index})
    ans(__end_index)


    list(LENGTH ARGN __insert_count)
    ## add new elements
    if(__insert_count)
      list(LENGTH ${__list_ref} __old_length)
      if("${__old_length}" EQUAL "${__start_index}")
        list(APPEND ${__list_ref} ${ARGN})
      else()
        list(INSERT ${__list_ref} ${__start_index} ${ARGN})
      endif()
      math(EXPR __start_index "${__start_index} + ${__insert_count}")
      math(EXPR __end_index "${__end_index} + ${__insert_count}")
    endif()
    
    ## generate index list of elements to remove
    index_range(${__start_index} ${__end_index})
    ans(__indices)

    ## get number of elements to remove
    list(LENGTH __indices __remove_count)
    
    ## get slice which is to be removed and remove it
    set(__removed_elements)
    if(__remove_count)
      list(GET ${__list_ref} ${__indices} __removed_elements)
      list(REMOVE_AT ${__list_ref} ${__indices})
    endif()
    

    ## set result
    set(${__list_ref} ${${__list_ref}} PARENT_SCOPE)
    return_ref(__removed_elements)
  endfunction()




# removes all items at all specified indices from list 
function(list_remove_at __list_remove_at_lst)
  if(NOT "${__list_remove_at_lst}")
    return()
  endif()
  set(args)

  foreach(arg ${ARGN})
      list_normalize_index(${__list_remove_at_lst} ${arg})
      ans(res)
      list(APPEND args ${res})
  endforeach()
  #list_select("${__list_remove_at_lst}" "(idx)->list_normalize_index($__list_remove_at_lst $idx)")
  #ans(args)



  list(REMOVE_AT "${__list_remove_at_lst}" ${args})

  set("${__list_remove_at_lst}" "${${__list_remove_at_lst}}" PARENT_SCOPE)

  return_ref("${__list_remove_at_lst}")  

endfunction()




## advances the iterator using list_iterator_next 
## and breaks the current loop when the iterator is done
macro(list_iterator_break it_ref)
  list_iterator_next(${it_ref})
  if(NOT __ans)
    break()
  endif()
endmacro()




# returns true if res is a vlaid reference and its type is 'list'
function(list_isvalid  ref )
	ref_isvalid("${ref}" )
	ans(isref)
	if(NOT isref)
		return(false)
	endif()
	ref_gettype("${ref}")
  ans(type)
	if(NOT "${type}" STREQUAL "list")
		return(false)
	endif()
	return(true)
endfunction()




function(list_values ref)
	list_isvalid( ${ref})
  ans(islist)
	if(NOT islist)
		return_value()
	endif()
	ref_get(${ref} )
  ans(values)
  return_ref(values)
endfunction()




function(list_new )
	ref_new(list ${ARGN})
  return_ans()
endfunction()




# takes the passed list and returns only its unique elements
# see cmake's list(REMOVE_DUPLICATES)
function(list_unique __list_unique_lst)
  list(LENGTH ${__list_unique_lst} __len)
  if(${__len} GREATER 1)
	 list(REMOVE_DUPLICATES ${__list_unique_lst})
  endif()
	return_ref(${__list_unique_lst})
endfunction()





## returns the length of the specified list
macro(list_length __list_count_lst)
    list(LENGTH "${__list_count_lst}" __ans)
endmacro()






  function(list_structure_print_help structure)
    map_keys(${structure} )
    ans(keys)

    set(descriptors)
    set(structure_help)
    foreach(key ${keys})

      map_get(${structure}  ${key})
      ans(descriptor)
      value_descriptor_parse(${key} ${descriptor})
      ans(descriptor)
      list(APPEND descriptors ${descriptor})

      scope_import_map(${descriptor})
      set(current_help)
      list(GET labels 0 first_label)
      set(current_help ${first_label})

      if(NOT "${default}_" STREQUAL "_")
        set(current_help "[${current_help} = ${default}]")
      elseif(${min} EQUAL 0 )
        set(current_help "[${current_help}]")
      endif()


      set(structure_help "${structure_help} ${current_help}")

    endforeach()
    if(structure_help)
      string(SUBSTRING "${structure_help}" 1 -1 structure_help)
    endif()
    message("${structure_help}")
    message("Details: ")
    foreach(descriptor ${descriptors})
      scope_import_map(${descriptor})
      list_to_string( labels ", ")
      ans(res)
      message("${displayName}: ${res}")
      if(description)
        message_indent_push()
        message("${description}")
        message_indent_pop()
      endif()

    endforeach()
  endfunction()






# parses a structured list given the structure map
# returning a map which contains all the parsed values
function(structured_list_parse structure_map)
  map_new()
  ans(result)
  set(args ${ARGN})
  obj("${structure_map}")
  ans(structure_map)

  if(NOT structure_map)
    return_ref(result)
  endif() 

  # get all keys
  map_keys(${structure_map} )
  ans(keys)
  set(cutoffs)

  # parse every value descriptor from structure map
  # add every label to the list of cutoffs (a new element definition cuts othe rvalues)
  set(descriptors)
  foreach(key ${keys})
    map_tryget(${structure_map}  "${key}")
    ans(current)
    if(current)
      value_descriptor_parse(${key} ${current})
      ans(current_descriptor)

      list(APPEND descriptors ${current_descriptor})
      map_tryget(${current_descriptor}  "labels")
      ans(labels)
      list(APPEND cutoffs ${labels})        
    endif()
  endforeach()

  # go through each descriptor
  set(errors)
  foreach(current_descriptor ${descriptors})
    nav(labels = current_descriptor.labels)
    nav(id = current_descriptor.id)
    list(REMOVE_ITEM cutoffs ${labels})

    set(error)
    list_parse_descriptor(${current_descriptor} ERROR error UNUSED_ARGS args CUTOFFS cutoffs ${args} )
    #message(FORMAT "args left ${args} after {current_descriptor.id}")
    ans(current_result)
    if(NOT current_result)
      nav(current_result = current_descriptor.default)
    endif()
    if(error)
      list(APPEND errors ${id})
    endif()
    string_semicolon_decode("${current_result}")
    ans(current_result)
    map_navigate_set("result.${id}" ${current_result})
  endforeach()
  #message("args left ${args}")
  map_navigate_set("result.unused" "${args}")
  map_navigate_set("result.errors" "${errors}")
  #message("errors ${errors}")
  return(${result})
endfunction()





# returns true if value could be parsed
function(list_parse_descriptor descriptor)  
  cmake_parse_arguments("" "" "UNUSED_ARGS;ERROR;CUTOFFS" "" ${ARGN})
  set(args ${_UNPARSED_ARGUMENTS})
  scope_import_map(${descriptor})
  list_find_any(args ${labels})
  ans(starting_index)

  list_slice(args 0 ${starting_index})
  ans(unused_args)
  list_slice(args ${starting_index} -1)
  ans(value_args)

  list_find_any(value_args ${${_CUTOFFS}})
  ans(cut_off)
  if(${cut_off} LESS 0)
    set(cut_off ${max})
  endif()
  math_min(${max} ${cut_off})
  ans(cut_off)

  #message(FORMAT "value args for {descriptor.id} max:${cut_off} are ${value_args} args: ${args}")

  # remove first arg as its the flag used to start this value
  list_pop_front( value_args)
  ans(used_label)
  
  # list length
  list(LENGTH value_args len)

  if("${cut_off}" STREQUAL "*")
    set(cut_off -1)
  endif()
  
  math_min(${len} ${cut_off})
  ans(cut_off)  
  list_slice(value_args "${cut_off}" -1)
  ans(tmp)

  list(APPEND unused_args ${tmp})

  # set result value for unused args
  if(_UNUSED_ARGS)
    set(${_UNUSED_ARGS} ${unused_args} PARENT_SCOPE)
  endif()
  
  list_slice(value_args 0 "${cut_off}")
  ans(value_args)

  # option
  if(${min} STREQUAL 0 AND ${max} STREQUAL 0)
    set(${_ERROR} false PARENT_SCOPE)
    if(starting_index LESS 0)
      return(false)
    else()
      return(true)
    endif()
  endif()

  # if less than min args are avaiable set error to true but
  # still return the found values however
  if(${cut_off} LESS ${min} )
    set(${_ERROR} true PARENT_SCOPE)
  else()
    set(${_ERROR} false PARENT_SCOPE)
  endif()


  # use return ref because value_args might return strange strings
  return_ref(value_args)

endfunction()




## assert allows assertion

# splits a list into two parts after the specified index
# example:
# set(lst 1 2 3 4 5 6 7)
# list_split(p1 p2 lst 3)
# p1 will countain 1 2 3
# p2 will contain 4 5 6 7
function(list_split part1 part2 _lst index)
	list(LENGTH ${_lst} count)
	#message("${count} ${${_lst}}")
	# subtract one because range goes to index count and should only got to count -1
	math(EXPR count "${count} -1")
	set(p1)
	set(p2)
	foreach(i RANGE ${count})
		#message("${i}")
		list(GET ${_lst} ${i} val)
		if(${i} LESS ${index} )
			list(APPEND p1 ${val})
		else()
			list(APPEND p2 ${val})
		endif()
	endforeach()
	set(${part1} ${p1} PARENT_SCOPE)
	set(${part2} ${p2} PARENT_SCOPE)
	return()
endfunction()







# returns the normalized index.  negative indices are transformed to i => length - i
# if the index is out of range after transformation -1 is returned and a warnign is issued
# note: index evaluating to length are valid (one behind last)
function(list_normalize_index __lst index )
  set(idx ${index})
  list(LENGTH ${__lst} length)

  if("${idx}" STREQUAL "*")
    set(idx ${length})
  endif()
  
  if(${idx} LESS 0)
    math(EXPR idx "${length} ${idx} + 1")
  endif()
  if(${idx} LESS 0)
    message(WARNING "index out of range: ${index} (${idx}) length of list '${lst}': ${length}")
    return(-1)
  endif()

  if(${idx} GREATER ${length})
    message(WARNING "index out of range: ${index} (${idx}) length of list '${lst}': ${length}")
    return(-1)
  endif()
  return(${idx})
endfunction()




# checks if the given list reference is an empty list
  function(list_isempty __list_empty_lst)
    list(LENGTH  ${__list_empty_lst} len)
    if("${len}" EQUAL 0)
      return(true)
    endif()
    return(false)
  endfunction()




  ## list_after(<list ref> <key:<string>>)-><any ....>
  ##
  ## returns the elements after the specified key
  function(list_after __lst __key)
    list(LENGTH ${__lst} __len)
    if(NOT __len)
      return()
    endif()
    list(FIND ${__lst} "${__key}" __idx)
    if(__idx LESS 0)
      return()
    endif()
    math(EXPR __idx "${__idx} + 1")
    list_split(__ __rhs ${__lst} ${__idx})
    return_ref(__rhs)
  endfunction()





# returns a list of numbers [ start_index, end_index)
# if start_index equals end_index the list is empty
# if end_index is less than start_index then the indices are in declining order
# ie index_range(5 3) => 5 4
function(index_range start_index end_index)
  
  if(${start_index} EQUAL ${end_index})
    return()
  endif()

  set(result)
  if(${end_index} LESS ${start_index})
    set(increment -1)
    math(EXPR end_index "${end_index} + 1")

  else()
    set(increment 1)
    math(EXPR end_index "${end_index} - 1")
  
  endif()
  
  foreach(i RANGE ${start_index} ${end_index} ${increment})
    list(APPEND result ${i})
  endforeach()
  return(${result})
endfunction()




# returns true if value ${a} comes before value ${b} in list __list_isinorder_lst
# sets ${result} to true or false
function(list_isinorder  __list_isinorder_lst a b)
	list(FIND ${__list_isinorder_lst} ${a} indexA)
	list(FIND ${__list_isinorder_lst} ${b} indexB)
	if(${indexA} LESS 0)
		return(false)
	endif()
	if(${indexB} LESS 0)
		return(false)
	endif()
	if(${indexA} LESS ${indexB})
		return(true)
	endif()
	return(false)
endfunction()




## returns a map of all found flags specified as ARGN
##  
function(list_find_flags __list_find_flags_lst)
  map_new()
  ans(__list_find_flags_result)
  foreach(__list_find_flags_itm ${ARGN})
    list(FIND "${__list_find_flags_lst}" "${__list_find_flags_itm}" __list_find_flags_item)
    if(NOT "${__list_find_flags_item}" LESS 0)
      map_set(${__list_find_flags_result} "${__list_find_flags_itm}" true)
    endif()
  endforeach()
  return(${__list_find_flags_result})
endfunction()




# sets the lists value at index to the specified value
# the index is normalized -> negativ indices count down from back of list 
  function(list_set_at __list_set_lst index value)
    if("${index}" EQUAL -1)
      #insert element at end
      list(APPEND ${__list_set_lst} ${value})
      set(${__list_set_lst} ${${__list_set_lst}} PARENT_SCOPE)
      return(true)
    endif()
    list_normalize_index(${__list_set_lst} "${index}")
    ans(index)
    if(index LESS 0)
      return(false)
    endif()
    list_replace_at(${__list_set_lst} "${index}" "${value}")

    set(${__list_set_lst} ${${__list_set_lst}} PARENT_SCOPE)
    return(true)
  endfunction()




# swaps the element of lst at i with element at index j
macro(list_swap __list_swap_lst i j)
	list(GET ${__list_swap_lst} ${i} a)
	list(GET ${__list_swap_lst} ${j} b)
	list_replace_at(${__list_swap_lst} ${i} ${b})
	list_replace_at(${__list_swap_lst} ${j} ${a})
endmacro()






# removes the specifed range from the list
# and returns remaining elements
function(list_without_range __list_without_range_lst start_index end_index)

  list_normalize_index(${__list_without_range_lst} -1)
  ans(list_end)

  list_slice(${__list_without_range_lst} 0 ${start_index})
  ans(part1)
  list_slice(${__list_without_range_lst} ${end_index} ${list_end})
  ans(part2)

  set(res ${part1} ${part2})
  return_ref(res)
endfunction()





# orders a list by a comparator function
function(list_sort __list_order_lst comparator)
  list(LENGTH ${__list_order_lst} len)

  function_import("${comparator}" as __compare REDEFINE)

  # copyright 2014 Tobias Becker -> triple s "slow slow sort"
  set(i 0)
  set(j 0)
  while(true)
    if(NOT ${i} LESS ${len})
      set(i 0)
      math(EXPR j "${j} + 1")
    endif()

    if(NOT ${j} LESS ${len}  )
      break()
    endif()
    list(GET ${__list_order_lst} ${i} a)
    list(GET ${__list_order_lst} ${j} b)
    #rcall(res = "${comparator}"("${a}" "${b}"))
    __compare("${a}" "${b}")
    ans(res)
    if(res LESS 0)
      list_swap(${__list_order_lst} ${i} ${j})
    endif()


    math(EXPR i "${i} + 1")
  endwhile()
  return_ref(${__list_order_lst})
endfunction()

## faster implementation: quicksort


# orders a list by a comparator function and returns it
function(list_sort __list_sort_lst comparator)
  list(LENGTH ${__list_sort_lst} len)
  math(EXPR len "${len} - 1")
  function_import("${comparator}" as __quicksort_compare REDEFINE)
  __quicksort(${__list_sort_lst} 0 ${len})
  return_ref(${__list_sort_lst})
endfunction()

   ## the quicksort routine expects a function called 
   ## __quicksort_compare to be defined
 macro(__quicksort __list_sort_lst lo hi)
  if("${lo}" LESS "${hi}")
    ## choose pivot
    set(p_idx ${lo})
    ## get value of pivot 
    list(GET ${__list_sort_lst} ${p_idx} p_val)
    
    list_swap(${__list_sort_lst} ${p_idx} ${hi})
    math(EXPR upper "${hi} - 1")
    
    ## store index p
    set(p ${lo})
    foreach(i RANGE ${lo} ${upper})
      list(GET ${__list_sort_lst} ${i} c_val)
      __quicksort_compare("${c_val}" "${p_val}")
      ans(cmp)
      if("${cmp}" GREATER 0)
        list_swap(${__list_sort_lst} ${p} ${i})
        math(EXPR p "${p} + 1")
      endif()
    endforeach()
    list_swap(${__list_sort_lst} ${p} ${hi})

    math(EXPR p_lo "${p} - 1")
    math(EXPR p_hi "${p} + 1")
    ## recursive call
    __quicksort("${__list_sort_lst}" "${lo}" "${p_lo}")
    __quicksort("${__list_sort_lst}" "${p_hi}" "${hi}")
  endif()
 endmacro()





# searchs lst for value and returns the first idx found
# returns -1 if value is not found
function(list_find __list_find_lst value)
  if(NOT "${__list_find_lst}")
    return(-1)
  endif()
  list(FIND ${__list_find_lst} "${value}" idx)
  return_ref(idx)
endfunction()









## matches all elements of lst to regex
## all elements in list which match the regex are returned
  function(list_regex_match __list_regex_match_lst )
    set(__list_regex_match_result)
    foreach(__list_regex_match_item ${${__list_regex_match_lst}})
      foreach(__list_regex_match_regex ${ARGN})
        if("${__list_regex_match_item}" MATCHES "${__list_regex_match_regex}")
          list(APPEND __list_regex_match_result "${__list_regex_match_item}")
          break() ## break inner loop on first match
        endif()
      endforeach()
    endforeach()
    return_ref(__list_regex_match_result)
  endfunction()




## returns the index of the one of the specified items
## if no element is found then -1 is returned 
## no guarantee is made on which item's index
## is returned 
function(list_find_any __list_find_any_lst )
  foreach(__list_find_any_item ${ARGN})
    list(FIND ${__list_find_any_lst} ${__list_find_any_item} __list_find_any_idx)
    if(${__list_find_any_idx} GREATER -1)
      return(${__list_find_any_idx})
    endif()
  endforeach()
  return(-1)
endfunction()






  function(list_to_map lst key_selector)
    function_import("${key_selector}" as __to_map_key_selector REDEFINE)
    map_new()
    ans(res)
    foreach(item ${${lst}})
      __to_map_key_selector(${item})
      ans(key)
      map_set(${res} "${key}" "${item}")
    endforeach()
    return_ref(res)

  endfunction()





# returns the the unique elements of list A without the elements of listB
function(list_difference __list_difference_lstA __list_difference_listB)
  if(NOT __list_difference_lstA)
    return()
  endif()
  if(NOT "${__list_difference_lstA}")
    return()
  endif()
  list(REMOVE_DUPLICATES ${__list_difference_lstA})
  foreach(__list_operation_item ${${__list_difference_listB}})
    list(REMOVE_ITEM ${__list_difference_lstA} ${__list_operation_item})
  endforeach()
  return_ref(${__list_difference_lstA})
endfunction()




## advances the iterator specified 
## and returns true if it is on a valid element (else false)
## sets the fields 
## ${it_ref}.index
## ${it_ref}.length
## ${it_ref}.list_ref
## ${it_ref}.value (only if a valid value exists)
function(list_iterator_next it_ref)
  list(GET ${it_ref} 0 list_ref)
  list(GET ${it_ref} 1 length)
  list(GET ${it_ref} 2 index)
  math(EXPR index "${index} + 1")    
  #print_vars(list_ref length index)
  set(${it_ref} ${list_ref} ${length} ${index} PARENT_SCOPE)
  set(${it_ref}.index ${index} PARENT_SCOPE)
  set(${it_ref}.length ${length} PARENT_SCOPE)
  set(${it_ref}.list_ref ${list_ref} PARENT_SCOPE)
  if(${index} LESS ${length})
    list(GET ${list_ref} ${index} value)
    set(${it_ref}.value "${value}" PARENT_SCOPE)
    return(true)
  else()
    set(${it_ref}.value PARENT_SCOPE)
    return(false)
  endif()
endfunction()





# gets the first element of the list without modififying it
function(list_peek_front __list_peek_front_lst)
  if("${${__list_peek_front_lst}}_" STREQUAL "_")
    return()
  endif()
  list(GET "${__list_peek_front_lst}" 0 res)
  return_ref(res)
endfunction()




## returns the maximum value in the list 
## using the specified comparerer function
function(list_max lst comparer)
  list_fold(${lst} "${comparer}")
  ans(res)
  return(${res})
endfunction()






  ## list_range_indices(<list&> <range ...>)
  ## returns the indices for the range for the specified list
  ## e.g. 
  ## 
  function(list_range_indices __lst)
    list(LENGTH ${__lst} len)
    range_indices("${len}" ${ARGN})
    ans(indices)
    return_ref(indices)
  endfunction()







## returns the elements of the specified list ref which are indexed by specified range
  function(list_range_get __lst_ref)
    list(LENGTH ${__lst_ref} __len)
    range_indices("${__len}" ${ARGN})
    ans(__indices)
    list(LENGTH __indices __len)
    if(NOT __len)
      return()
    endif()
    list(GET ${__lst_ref} ${__indices} __res)
    return_ref(__res)
  endfunction()





## removes the specified range from the list
function(list_range_remove __lst range)
  list(LENGTH ${__lst} list_len)
  range_indices(${list_len} "${range}")
  ans(indices)
  list(LENGTH indices len)

  if(NOT len)
    return(0)
  endif()
  #message("${indices} - ${list_len}")
  if("${indices}" EQUAL ${list_len})
    return(0)
  endif()
  list(REMOVE_AT ${__lst} ${indices})
  set(${__lst} ${${__lst}} PARENT_SCOPE)
  return(${len})
endfunction()





  function(range_instanciate length)
    range_parse(${ARGN})
    ans(range)

    if(${length} LESS 0)
      set(length 0)
    endif()

    math(EXPR last "${length}-1")

    set(result)
    foreach(part ${range})
      string(REPLACE : ";" part ${part})
      set(part ${part})
      list(GET part 0 begin)
      list(GET part 1 end)
      list(GET part 2 increment)
      list(GET part 3 begin_inclusivity)
      list(GET part 4 end_inclusivity)
      list(GET part 5 range_length)
      list(GET part 6 reverse)

      string(REPLACE "n" "${length}" range_length "${range_length}")
      string(REPLACE "$" "${last}" range_length "${range_length}")
  
      math(EXPR range_length "${range_length}")


      string(REPLACE "n" "${length}" end "${end}")
      string(REPLACE "$" "${last}" end "${end}")
  
      math(EXPR end "${end}")
      if(${end} LESS 0)
        message(FATAL_ERROR "invalid range end: ${end}")
      endif()

      string(REPLACE "n" "${length}" begin "${begin}")
      string(REPLACE "$" "${last}" begin "${begin}")
      math(EXPR begin "${begin}")
      if(${begin} LESS 0)
        message(FATAL_ERROR "invalid range begin: ${begin}")
      endif()

      list(APPEND result "${begin}:${end}:${increment}:${begin_inclusivity}:${end_inclusivity}:${range_length}:${reverse}")  
    endforeach()
   # message("res ${result}")
    return_ref(result)
  endfunction()






## returns the elements of the specified list ref which are indexed by specified range
  function(list_range_try_get __lst_ref)
    list(LENGTH ${__lst_ref} __len)
    range_indices("${__len}" ${ARGN})
    ans(__indices2)

    set(__indices)
    foreach(__idx ${__indices2})
      if(NOT ${__idx} LESS 0 AND ${__idx} LESS ${__len} )
        list(APPEND __indices ${__idx})
      endif()
    endforeach()

    list(LENGTH __indices __len)
    if(NOT __len)
      return()
    endif()
    list(GET ${__lst_ref} ${__indices} __res)
    return_ref(__res)
  endfunction()






  function(range_parse)
    string(REPLACE " " ";" range "${ARGN}")
    string(REPLACE "," ";" range "${range}")

    string(REPLACE "(" ">" range "${range}")
    string(REPLACE ")" "<" range "${range}")
    string(REPLACE "[" "<" range "${range}")
    string(REPLACE "]" ">" range "${range}")

    list(LENGTH range group_count)

    set(ranges)
    if(${group_count} GREATER 1)
      foreach(group ${range})
        range_parse("${group}")
        ans(current)
        list(APPEND ranges "${current}")
      endforeach()
      return_ref(ranges)
    endif()


    set(default_begin_inclusivity)
    set(default_end_inclusivity)



    string(REGEX REPLACE "([^<>])+" "_" inclusivity "${range}")
    set(inclusivity "${inclusivity}___")
    string(SUBSTRING ${inclusivity} 0 1 begin_inclusivity )
    string(SUBSTRING ${inclusivity} 1 1 end_inclusivity )
    string(SUBSTRING ${inclusivity} 2 1 three )
    if(${end_inclusivity} STREQUAL _)
      set(end_inclusivity ${three})
    endif()



    if("${begin_inclusivity}" STREQUAL "<")
      set(begin_inclusivity true)
    elseif("${begin_inclusivity}" STREQUAL ">")
      set(begin_inclusivity false)
    else()
     set(begin_inclusivity true)
     set(default_begin_inclusivity true) 
    endif()

    if("${end_inclusivity}" STREQUAL "<")
      set(end_inclusivity false)
    elseif("${end_inclusivity}" STREQUAL ">")
      set(end_inclusivity true)
    else()
      set(end_inclusivity true)
      set(default_end_inclusivity true)
    endif()

    # if("${range}" MATCHES "INC_BEGIN")
    #  set(begin_inclusivity true)
    # elseif("${range}" MATCHES "EXC_BEGIN")
    #   set(begin_inclusivity false)
    # else()
    #    set(begin_inclusivity true)
    #    set(default_begin_inclusivity true)
    # endif()

    #  if("${range}" MATCHES "INC_END")
    #    set(end_inclusivity true)
    #  elseif("${range}" MATCHES "EXC_END")
    #    set(end_inclusivity false)
    #  else()
    #    set(default_end_inclusivity true)
    #    set(end_inclusivity true)
    #  endif()

    # # #message("inc ${range} ${begin_inclusivity} ${end_inclusivity}")

    #  string(REPLACE "INC_BEGIN" "" range "${range}")
    #  string(REPLACE "INC_END" "" range "${range}")
    #  string(REPLACE "EXC_BEGIN" "" range "${range}")
    #  string(REPLACE "EXC_END" "" range "${range}")
    string(REGEX REPLACE "[<>]" "" range "${range}")

    if("${range}_" STREQUAL "_")
      set(range "n:n:1")
      if(default_end_inclusivity)
        set(end_inclusivity false)
      endif()
    endif()

    if("${range}" STREQUAL "*")
      set(range "0:n:1")
    endif()

    if("${range}" STREQUAL ":")
      set(range "0:$:1")
    endif()


    

    
    string(REPLACE  ":" ";" range "${range}")
    

    list(LENGTH range part_count)
    if(${part_count} EQUAL 1)
      set(range ${range} ${range} 1)
    endif()

    if(${part_count} EQUAL 2)
      list(APPEND range 1)
    endif()

    list(GET range 0 begin)
    list(GET range 1 end)
    list(GET range 2 increment)
    ##message("partcount ${part_count}")
    if(${part_count} GREATER 3)
      list(GET range 3 begin_inclusivity)
    endif()
    if(${part_count} GREATER 4)
      list(GET range 4 end_inclusivity)
    endif()

    # #message("inc ${range} ${begin_inclusivity} ${end_inclusivity}")


    if((${end} LESS ${begin} AND ${increment} GREATER 0) OR (${end} GREATER ${begin} AND ${increment} LESS 0))
      return()
    endif()

    set(reverse false)
    if(${begin} GREATER ${end})
      set(reverse true)
    endif()

    if(${begin} STREQUAL -0)
      set(begin $)
    endif()

    if(${end} STREQUAL -0)
      set(end $)
    endif()


    set(begin_negative false)
    set(end_negative false)
    if(${begin} LESS 0)
      set(begin "($${begin})")
      set(begin_negative true)
    endif()
    if(${end} LESS 0)
      set(end "($${end})")
      set(end_negative true)
    endif()

    if("${begin}" MATCHES "[\\-\\+]")
      set(begin "(${begin})")
    endif()
    if("${end}" MATCHES "[\\-\\+]")
      set(end "(${end})")
    endif()


    if(NOT reverse)
      set(length "${end}-${begin}")
      if(end_inclusivity)
        set(length "${length}+1")
      endif()
      if(NOT begin_inclusivity)
        set(length "${length}-1")
      endif()
    else()
      #message("reverse begin ${begin} end ${end}")
      set(length "${begin}-${end}")
      if(begin_inclusivity)
        set(length "${length}+1")
      endif()
      if(NOT end_inclusivity)
        set(length "${length}-1")
      endif()
    endif()
    string(REPLACE "n-n" "0" length "${length}")
    string(REPLACE "n-$" "1" length "${length}")
    string(REPLACE "$-n" "0-1" length "${length}")
    string(REPLACE "$-$" "0" length "${length}")
    #message("length ${length}")

    if("${increment}" GREATER 1)
      set(length "(${length}-1)/${increment}+1")
    elseif("${increment}" LESS -1)
      set(length "(${length}-1)/(0-(0${increment}))+1")
    elseif(${increment} EQUAL 0)
      set(length 1)
    endif()
    #message("length ${length}")
    if(NOT "${length}" MATCHES "\\$|n" )
      math(EXPR length "${length}")
    else()
       # 
    endif()
    set(range "${begin}:${end}:${increment}:${begin_inclusivity}:${end_inclusivity}:${length}:${reverse}")
    #message("range '${range}'\n")
 
    return_ref(range)
  endfunction()





  ## replaces the specified range with the specified arguments
  ## the varags are taken and fill up the range to replace_count
  ## e.g. set(list a b c d e) 
  ## list_range_replace(list "4 0 3:1:-2" 1 2 3 4 5) --> list is equal to  2 4 c 3 1 
  ##
  function(list_range_replace lst_ref range)
    set(lst ${${lst_ref}})

    list(LENGTH lst len)
    range_instanciate(${len} "${range}")
    ans(range)

    set(replaced)
    message("inputlist '${lst}' length : ${len} ")
    message("range: ${range}")
    set(difference)

    range_indices("${len}" ":")
    ans(indices)
    
    range_indices("${len}" "${range}")
    ans(indices_to_replace)
    
    list(LENGTH indices_to_replace replace_count)
    message("indices_to_replace '${indices_to_replace}' count: ${replace_count}")

    math(EXPR replace_count "${replace_count} - 1")

    if(${replace_count} LESS 0)
      message("done\n")
      return()
    endif()

    set(args ${ARGN})
    set(replaced)

    message_indent_push()
    foreach(i RANGE 0 ${replace_count})
      list(GET indices_to_replace ${i} index)

      list_pop_front(args)
      ans(current_value)

      #if(${i} EQUAL ${replace_count})
      #  set(current_value ${args})
      #endif()

      if(${index} GREATER ${len})
        message(FATAL_ERROR "invalid index '${index}' - list is only ${len} long")
      elseif(${index} EQUAL ${len}) 
        message("appending to '${current_value}' to list")
        list(APPEND lst "${current_value}")
      else()
        list(GET lst ${index} val)
        list(APPEND replaced ${val})
        message("replacing '${val}' with '${current_value}' at '${index}'")
        list(INSERT lst ${index} "${current_value}")
        #list(LENGTH current_value current_len)
        math(EXPR index "${index} + 1")
        list(REMOVE_AT lst ${index})
        message("list is now ${lst}")
      endif()



    endforeach()
    message_indent_pop()


    message("lst '${lst}'")
    message("replaced '${replaced}'")
    message("done\n")
    set(${lst_ref} ${lst} PARENT_SCOPE)
    return_ref(replaced)
  endfunction()










  ## returns the list of indices for the specified range
  ## length may be -1 which causes a failure if the $ or n are used in the range
  ## if range is a valid length (>-1) then only valid indices are returned or a 
  ## failure occurs
  ## a length of 0 always returns no indices
  function(range_indices length)

    if("${length}" EQUAL 0)
      return()
    endif()
    if("${length}" LESS 0)
      set(length 0)
    endif()
    range_instanciate("${length}" ${ARGN})
    ans(range)
    set(indices)

    foreach(partial ${range})
      string(REPLACE ":" ";" partial "${partial}")
      list(GET partial 0 1 2 partial_range)
      foreach(i RANGE ${partial_range})
        list(APPEND indices ${i})
      endforeach() 
      list(GET partial 3 begin_inclusivity)
      list(GET partial 4 end_inclusivity)
      if(NOT end_inclusivity)
        list_pop_back(indices)
      endif()
      if(NOT begin_inclusivity)
        list_pop_front(indices)
      endif()
    endforeach()
   # message("indices for len '${length}' (range ${range}): '${indices}'")
    return_ref(indices)
  endfunction()






  ## tries to simplify the specified range for the given length
  function(range_simplify length)
    set(args ${ARGN})

    list_pop_front(args)
    ans(current_range)

    range_indices("${length}" "${current_range}")
    ans(indices)

    while(true)
      #print_vars(indices)
      list(LENGTH args indices_length)
      if(${indices_length} EQUAL 0)
        break()
      endif()
      list_pop_front(args)
      ans(current_range)
      #print_vars(current_range)
      list_range_get(indices "${current_range}")
      ans(indices)
    endwhile()


    #print_vars(indices)
    range_from_indices(${indices})
    return_ans()
  endfunction()




# returns ranges from the specified indices
## e.g range_from_indices(1 2 3) -> [1:3]
##     range_from_indices(1 2) -> 1 2
##     range_from_indices(1 2 3 4 5 6 7 8 4 3 2 1 9 6 7) -> [1:8] [4:1:-1] 9 6 7
  function(range_from_indices)
    set(range)
    set(prev)
    set(begin -1)
    set(end -1)
    set(increment)
    list(LENGTH ARGN index_count)
    if(${index_count} EQUAL 0)
      return()
    endif() 

   # message("index coutn ${index_count} :${ARGN}")

    set(indices_in_partial_range)
    foreach(i ${ARGN})
      if("${begin}"  EQUAL -1)
        set(begin ${i})
        set(end ${i})
      endif()


      if(NOT increment)
        math(EXPR increment "${i} - ${begin}")
        if( ${increment} GREATER 0)
          set(increment "+${increment}")
        elseif(${increment} EQUAL 0)
          set(increment)
        endif()
      endif()

      if(increment)
        math(EXPR expected "${end}${increment}")    
      else()
        set(expected ${i})
      endif()

    #  print_vars(increment expected indices_in_partial_range)

      if(NOT ${expected} EQUAL ${i})
        __range_from_indices_create_range()
        ## end of current range
        set(begin ${i})
        set(increment)
        set(indices_in_partial_range)

      endif()
      set(end ${i}) 
      list(APPEND indices_in_partial_range ${i})
    endforeach()

    __range_from_indices_create_range()
    


    string(REPLACE ";" " " range "${range}")
    #message("res '${range}'")
    return_ref(range)
  endfunction()
  macro(__range_from_indices_create_range)
      list(LENGTH indices_in_partial_range number_of_indices)
   #   message("done with range: ${begin} ${end} ${increment} ${number_of_indices}")

      if(${number_of_indices} EQUAL 2)
        list(APPEND range "${begin}")
        list(APPEND range "${end}")
      elseif("${begin}" EQUAL "${end}")
        list(APPEND range "${begin}")
      elseif("${increment}" EQUAL 1)
        list(APPEND range "[${begin}:${end}]")
      else()
        math(EXPR increment "0${increment}")
        list(APPEND range "[${begin}:${end}:${increment}]")
      endif()
  endmacro()




  ## sets every element included in range to specified value
  ## 
  function(list_range_set __lst __range __value)
    list_range_indices(${__lst} "${__range}")
    ans(indices)
    foreach(i ${indices})
      list(INSERT "${__lst}" "${i}" "${__value}")
      math(EXPR i "${i} + 1")
      list(REMOVE_AT "${__lst}" "${i}")
    endforeach()
    set(${__lst} ${${__lst}} PARENT_SCOPE)
    return()
  endfunction()





## writes the specified varargs to the list
## at the beginning of the specified partial range
## fails if the range is a  multi range
## e.g. 
## set(lstB a b c)
## list_range_partial_write(lstB "[]" 1 2 3)
## -> lst== [a b c 1 2 3]
## list_range_partial_write(lstB "[1]" 1 2 3)
## -> lst == [a 1 2 3 c]
## list_range_partial_write(lstB "[1)" 1 2 3)
## -> lst == [a 1 2 3 b c]
  function(list_range_partial_write __lst __range)
    range_parse("${__range}")
    ans(partial_range)
    list(LENGTH partial_range len)
    if("${len}" GREATER 1)
      message(FATAL_ERROR "only partial partial_range allowed")
      return()
    endif()
   # print_vars(partial_range)

    string(REPLACE ":" ";" partial_range "${partial_range}")
    list(GET partial_range 0 begin)
    list(GET partial_range 1 end)

    if("${begin}" STREQUAL "n" AND "${end}" STREQUAL "n")
      set(${__lst} ${${__lst}} ${ARGN} PARENT_SCOPE)
      return()
    endif()

    list_range_remove("${__lst}" "${__range}")

    list(LENGTH ARGN insertion_count)
    if(NOT insertion_count)
      set(${__lst} ${${__lst}} PARENT_SCOPE)
      return()
    endif() 

    list(GET partial_range 6 reverse)
    if(reverse)
      set(insertion_index "${end}")
    else()
      set(insertion_index "${begin}")
    endif()

    list(LENGTH ${__lst} __len)
    if("${insertion_index}" LESS ${__len})
      list(INSERT ${__lst} "${insertion_index}" ${ARGN})
    elseif("${insertion_index}" EQUAL ${__len})
      list(APPEND ${__lst} ${ARGN})
    else()
      message(FATAL_ERROR "list_range_partial_write could not write to index ${insertion_index}")
    endif()


    set(${__lst} ${${__lst}} PARENT_SCOPE)
    return()
  endfunction()






  function(range_partial_unpack ref)
    if(NOT ${ref})
      set(${ref} ${ARGN})
    endif()
    set(partial ${${ref}})

    string(REPLACE ":" ";" parts ${partial})
    list(GET parts 0 begin)
    list(GET parts 1 end)
    list(GET parts 2 increment)
    list(GET parts 3 inclusive_begin)
    list(GET parts 4 inclusive_end)
    list(GET parts 5 length)
    
    set(${ref}.inclusive_begin ${inclusive_begin} PARENT_SCOPE)
    set(${ref}.inclusive_end ${inclusive_end} PARENT_SCOPE)    
    set(${ref}.begin ${begin} PARENT_SCOPE)
    set(${ref}.end ${end} PARENT_SCOPE)
    set(${ref}.increment ${increment} PARENT_SCOPE)
    set(${ref}.length  ${length} PARENT_SCOPE)
  endfunction()






# returns only those flags which are contained in list and in the varargs
# ie list = [--a --b --c --d]
# list_intersect_args(list --c --d --e) ->  [--c --d]
function(list_intersect_args __list_intersect_args_lst)
  set(__list_intersect_args_flags ${ARGN})
  list_intersect(${__list_intersect_args_lst} __list_intersect_args_flags)
  return_ans()
endfunction()





# extracts all of the specified flags and returns true if any of them were found
function(list_extract_any_flag __list_extract_any_flag_lst)
  list_extract_flags("${__list_extract_any_flag_lst}" ${ARGN})
  set("${__list_extract_any_flag_lst}" ${${__list_extract_any_flag_lst}} PARENT_SCOPE)
  ans(flag_map)
  map_keys(${flag_map})
  ans(found_keys)
  list(LENGTH found_keys len)
  if(${len} GREATER 0)
    return(true)
  endif()
  return(false)
endfunction()







# uses the selector on each element of the list
function(list_select __list_select_lst selector)
  list(LENGTH ${__list_select_lst} l)
  message(list_select ${l})
  set(__list_select_result_list)

  foreach(item ${${__list_select_lst}})
		rcall(res = "${selector}"("${item}"))
		list(APPEND __list_select_result_list ${res})

	endforeach()
  message("list_select end")
	return_ref(__list_select_result_list)
endfunction()



## fast implementation of list_select
function(list_select __list_select_lst __list_select_selector)
  function_import("${__list_select_selector}" as __list_select_selector REDEFINE)

  set(__res)
  set(__ans)
  foreach(__list_select_current_arg ${${__list_select_lst}})
    __list_select_selector(${__list_select_current_arg})
    list(APPEND __res ${__ans})
  endforeach()
  return_ref(__res)  
endfunction()




## returns all possible combinations of the specified lists
## e.g.
## set(range 0 1)
## list_combinations(range range range) -> 000 001 010 011 100 101 110 111
 function(list_combinations)
    set(lists ${ARGN})
    list_length(lists)
    ans(len)

    if(${len} LESS 1)
      return()
    elseif(${len} EQUAL 1)
      return_ref(${lists})
    elseif(${len} EQUAL 2)
      list_extract(lists __listA __listB)
      set(__result)
      foreach(elementA ${${__listA}})
        foreach(elementB ${${__listB}})
          list(APPEND __result "${elementA}${elementB}")
        endforeach()
      endforeach()
      return_ref(__result)
    else()
      list_pop_front(lists)
      ans(___listA)

      list_combinations(${lists})
      ans(___listB)

      list_combinations(${___listA} ___listB)
      return_ans()
    endif()
  endfunction()




# removes all items specified in varargs from list
function(list_remove __list_remove_lst)
  list(LENGTH "${__list_remove_lst}" __lst_len)
  list(LENGTH ARGN __arg_len)
  if(__arg_len EQUAL 0 OR __lst_len EQUAL 0)
    return()
  endif()

  list(REMOVE_ITEM "${__list_remove_lst}" ${ARGN})
  set("${__list_remove_lst}" "${${__list_remove_lst}}" PARENT_SCOPE)
  return_ref("${__list_remove_lst}")
endfunction()




# folds the specified list into a single result by recursively applying the aggregator
function(list_fold lst aggregator)
  if(NOT "_${ARGN}" STREQUAL _folding)
    function_import("${aggregator}" as __list_fold_folder REDEFINE)
  endif()
  set(rst ${${lst}})
  list_pop_front(rst)
  ans(left)
  
  if("${rst}_" STREQUAL "_")
    return(${left})
  endif()


  list_fold(rst "" folding)
  ans(right)
  __list_fold_folder("${left}" "${right}")

  ans(res)

 # message("left ${left} right ${right} => ${res}")
  return(${res})
endfunction()



## faster non recursive version
function(list_fold lst aggregator)
  if(NOT "_${ARGN}" STREQUAL _folding)
    function_import("${aggregator}" as __list_fold_folder REDEFINE)
  endif()

  set(rst ${${lst}})
  list_pop_front(rst)
  ans(left)
  
  if("${rst}_" STREQUAL "_")
    return(${left})
  endif()

  set(prev "${left}")
  foreach(item ${rst})
    __list_fold_folder("${prev}" "${item}")
    ans(prev)
  endforeach()
  return_ref(prev)



endfunction()





# replaces lists  value at i with new_value
function(list_replace_at __list_replace_at_lst i new_value)
  list(LENGTH ${__list_replace_at_lst} len)
  if(NOT "${i}" LESS "${len}")
    return(false)
  endif()
  list(INSERT ${__list_replace_at_lst} ${i} ${new_value}) 
  math(EXPR i_plusone "${i} + 1" )
  list(REMOVE_AT ${__list_replace_at_lst} ${i_plusone})
  set(${__list_replace_at_lst} ${${__list_replace_at_lst}} PARENT_SCOPE)
  return(true)
endfunction()





## extracts any of the specified labelled values and returns as soon 
## the first labelled value is found
## lst contains its original elements without the labelled value 
function(list_extract_any_labelled_value __list_extract_any_labelled_value_lst)
  set(__list_extract_any_labelled_value_res)
  foreach(label ${ARGN})
    list_extract_labelled_value(${__list_extract_any_labelled_value_lst} ${label})
    ans(__list_extract_any_labelled_value_res)
    if(NOT "${__list_extract_any_labelled_value_res}_" STREQUAL "_")    
      break()
    endif()
  endforeach()
  set(${__list_extract_any_labelled_value_lst} ${${__list_extract_any_labelled_value_lst}}  PARENT_SCOPE)
  return_ref(__list_extract_any_labelled_value_res)
endfunction()





## returns true iff predicate holds 
## for all elements of lst 
function(list_all __list_all_lst __list_all_predicate)
  function_import("${__list_all_predicate}" as __list_all_predicate REDEFINE)
  foreach(it ${${__list_all_lst}})
    __list_all_predicate("${it}")
    ans(__list_all_match)
    if(NOT __list_all_match)
      return(false)
    endif()
  endforeach()
  return(true)
endfunction()




# return those elemnents of minuend that are not in subtrahend
function(list_except __list_except_minuend list_except_subtrahend)
	set(__list_except_result)
	foreach(__list_except_current ${${__list_except_minuend}})
		list(FIND ${list_except_subtrahend} "${__list_except_current}" __list_except_idx)
		if(${__list_except_idx} LESS 0)
			list(APPEND __list_except_result ${__list_except_current})
		endif()
	endforeach()
  return_ref(__list_except_result)
endfunction()




# retruns true iff lhs and rhs are the same set (ignoring duplicates)
# the null set is only equal to the null set 
# the order of the set (as implied in being a set) does not matter
function(set_isequal __set_equal_lhs __set_equal_rhs)
  set_issubset(${__set_equal_lhs} ${__set_equal_rhs})
  ans(__set_equal_lhsIsInRhs)
  set_issubset(${__set_equal_rhs} ${__set_equal_lhs})
  ans(__set_equal_rhsIsInLhs)
  if(__set_equal_lhsIsInRhs AND __set_equal_rhsIsInLhs)
    return(true)
  endif() 
  return(false)
endfunction()




# returns true iff lhs is subset of rhs
# duplicate elements in lhs and rhs are ignored
# the null set is subset of every set including itself
# no other set is subset of the null set
# if rhs contains all elements of lhs then lhs is the subset of rhs
function(set_issubset __set_is_subset_of_lhs __set_is_subset_of_rhs)
  list(LENGTH ${__set_is_subset_of_lhs} __set_is_subset_of_length)
  if("${__set_is_subset_of_length}" EQUAL "0")
    return(true)
  endif()
  list(LENGTH ${__set_is_subset_of_rhs} __set_is_subset_of_length)
  if("${__set_is_subset_of_length}" EQUAL "0")
    return(false)
  endif()
  foreach(__set_is_subset_of_item ${${__set_is_subset_of_lhs}})
    list(FIND ${__set_is_subset_of_rhs} "${__set_is_subset_of_item}" __set_is_subset_of_idx)
    if("${__set_is_subset_of_idx}" EQUAL "-1")
      return(false)
    endif()
  endforeach()
  return(true)
endfunction()






# removes the first value of the list and returns it
function(list_pop_front  __list_pop_front_lst)
  set(res)

  list(LENGTH "${__list_pop_front_lst}" len)
  if("${len}" EQUAL 0)
    return()
  endif()

  list(GET ${__list_pop_front_lst} 0 res)

  if(${len} EQUAL 1) 
    set(${__list_pop_front_lst} )
  else()
    list(REMOVE_AT "${__list_pop_front_lst}" 0)
  endif()
  #message("${__list_pop_front_lst} is ${${__list_pop_front_lst}}")
#  set(${result} ${res} PARENT_SCOPE)
  set(${__list_pop_front_lst} ${${__list_pop_front_lst}} PARENT_SCOPE)
  return_ref(res)
endfunction()


# removes the first value of the list and returns it
## faster version
macro(list_pop_front  __list_pop_front_lst)
  list(LENGTH "${__list_pop_front_lst}" __list_pop_front_length)
  if(NOT "${__list_pop_front_length}" EQUAL 0)
    list(GET ${__list_pop_front_lst} 0 __ans)

    if(${__list_pop_front_length} EQUAL 1) 
      set(${__list_pop_front_lst})
    else()
      list(REMOVE_AT "${__list_pop_front_lst}" 0)
    endif()
  else()
    set(__ans)
  endif()

endmacro()





function(list_select_property __lst __prop)
  set(__result)
  foreach(__itm ${${__lst}})
    map_tryget("${__itm}" "${__prop}")
    ans(__res)
    list(APPEND __result "${__res}")
  endforeach()
  return_ref(__result)
endfunction()






# Converts a CMake list to a string containing elements separated by spaces
function(list_to_string  list_name separator )
  set(res)
  set(current_separator)
  foreach(element ${${list_name}})
    set(res "${res}${current_separator}${element}")
    # after first iteration separator will be set correctly
    # so i do not need to remove initial separator afterwords
    set(current_separator ${separator})
  endforeach()
  return_ref(res)

endfunction()





## list_split_at()
##
##
function(list_split_at lhs rhs __lst key)
  list(LENGTH ${__lst} len)
  if(NOT len)
    set(${lhs} PARENT_SCOPE)
    set(${rhs} PARENT_SCOPE)
    return()
  endif()

  list(FIND ${__lst} ${key} idx)

  list_split(${lhs} ${rhs} ${__lst} ${idx})

  set(${lhs} ${${lhs}} PARENT_SCOPE)
  set(${rhs} ${${rhs}} PARENT_SCOPE)

  return()
endfunction()




# returns a list containing the unqiue set of all elements
# contained in passed list referencese
function(list_union)
  if(NOT ARGN)
    return()
  endif()
  set(__list_union_result)
  foreach(__list_union_list ${ARGN})
    list(APPEND __list_union_result ${${__list_union_list}})
  endforeach() 

  list(REMOVE_DUPLICATES __list_union_result)
  return_ref(__list_union_result)
endfunction()





## returns true if there exists an element
## for which the predicate holds
function(list_any __list_any_lst __list_any_predicate)
  function_import("${__list_any_predicate}" as __list_any_predicate REDEFINE)
  foreach(item ${${__list_any_lst}})
    __list_any_predicate("${item}")
    ans(__list_any_predicate_holds)
    if(__list_any_predicate_holds)
      return(true)
    endif()
  endforeach()
  return(false)
endfunction()







## returns every element of lst that matches any of the given regexes
## and does not match any regex that starts with !
  function(list_regex_match_ignore lst)
    set(regexes ${ARGN})
    list_regex_match(regexes "^[!]")
    ans(negs)
    set(negatives)
    foreach(negative ${negs})
      string(SUBSTRING "${negative}" 1 -1 negative )
      list(APPEND negatives "${negative}")
    endforeach()

    list_regex_match(regexes "^[^!]")
    ans(positives)


    list_regex_match(${lst} ${positives})
    ans(matches)

    list_regex_match(matches ${negatives})
    ans(ignores)

    list(REMOVE_ITEM matches ${ignores})

    return_ref(matches)

  endfunction()





## gets the labelled value from the specified list
## set(thelist a b c d)
## list_get_labelled_value(thelist b) -> c
function(list_get_labelled_value __list_get_labelled_value_lst __list_get_labelled_value_value)
  list_extract_labelled_value(${__list_get_labelled_value_lst} ${__list_get_labelled_value_value} ${ARGN})
  return_ans()
endfunction()




   
      function(list_remove_duplicates __lst)
        list(LENGTH ${__lst} len)
        if(len EQUAL 0)
          return()
        endif()
        list(REMOVE_DUPLICATES repos)
        return()
      endfunction()




  #extracts a single flag from a list returning true if it was found
  # false otherwise. 
  # if flag exists multiple time online the first instance of the flag is removed
  # from the list
 function(list_extract_flag __list_extract_flag flag)
    list(FIND "${__list_extract_flag}" "${flag}" idx)
    if(${idx} LESS 0)
      return(false)     
    endif()
    list(REMOVE_AT "${__list_extract_flag}" "${idx}") 
    set("${__list_extract_flag}" "${${__list_extract_flag}}" PARENT_SCOPE)
    return(true)
endfunction()






# executes a predicate on every item of the list (passed by reference)
# and returns those items for which the predicate holds
function(list_where __list_where_lst predicate)

	foreach(item ${${__list_where_lst}})
    rcall(__matched = "${predicate}"("${item}"))
		if(__matched)
			list(APPEND result_list ${item})
		endif()
	endforeach()
	return_ref(result_list)
endfunction()


## fast implemenation
function(list_where __list_where_lst __list_where_predicate)
  function_import("${__list_where_predicate}" as __list_where_predicate REDEFINE)
  set(__list_where_result_list)
  foreach(__list_where_item ${${__list_where_lst}})
    __list_where_predicate(${__list_where_item})
    ans(__matched)
    if(__matched)
      list(APPEND __list_where_result_list ${__list_where_item})
    endif()
  endforeach()
  return_ref(__list_where_result_list)
endfunction()





function(CommandRunner)
	# field containing all command name => handler mappings
	map_new()
  ans(commands)
	this_set(commands ${commands})

	# name for this command runner
	this_set(name "CommandRunner")

	this_declare_call(callfunc)
	function(${callfunc})		
		call(this.Run(${ARGN}))
		return_ans()
	endfunction()

	## Adds a commandhandler to this CommandRunner
	## this command_name must be unique
	## command_handler must be either a function or a functor
	proto_declarefunction(AddCommandHandler)
	function(${AddCommandHandler} command_name command_handler)
		this_import(commands)
		#message("adding ${command_name}")
		map_has(${commands}  ${command_name})
		ans(has_command)
		if( has_command)
			#ref_print(${commands})
		#	message(FATAL_ERROR "${name}> AddCommandHandler: command '${command_name}' was already added")
		endif()
		

		map_set(${commands} ${command_name} "${command_handler}")
	endfunction()

	## the run method uses the first argument cmd to lookup a command handler
	## if the commandhandler is found it will be called
	proto_declarefunction(Run)
	function(${Run})
		this_import(commands)

		set(args ${ARGN}) 
		set(cmd)
		## check if any argument was specifed and set the cmd to the first one
		if(args)
			list_pop_front(args)
			ans(cmd)
		endif()

		# if no command is set return error message
		if(NOT cmd)
			message("${name}> no command specified (try 'help')")
			return()
		endif()
		# try to get a handler for the command if none is found return error message
		map_tryget("${commands}"  "${cmd}")
		ans(handler)
		if(NOT handler)		
			message("${name}> could not find a command called '${cmd}' (try 'help')")
			return()
		endif()

		call("${handler}" (${args}))
		return_ans()
	endfunction()

	## the default help function.
	## prints out all declared commands of this handler
	proto_declarefunction(Help)
	function(${Help})
		# go through all keys and print them...
		map_keys(${commands} )
		ans(keys)
		message(STATUS "${name}> available commands for ${name}: ")
		foreach(key ${keys})
			message(STATUS "  ${key}")
		endforeach()
	endfunction()
	# register the command
	obj_member_call(${this} AddCommandHandler help ${Help})



endfunction()




function(Object)
	#formats the current object 
	proto_declarefunction(to_string)

	function(${to_string} )
		set(res)
#		debug_message("to_string object ${this}")
		obj_keys(${this} keys)

		foreach(key ${keys})
			obj_get(${this}  ${key})				
			ans(value)
			map_has(${this}  ${key})
			ans(is_own)	
			if(value)
				is_function(function_found ${value})
				is_object(object_found ${value})
			endif()
			
			
			if(function_found)
				set(value "[function]")
			elseif(object_found)
				get_filename_component(fn ${value} NAME_WE)
				obj_gettype(${value} )
				ans(type)
				if(NOT type)
					set(type "")
				endif()
				set(value "[object ${type}:${fn}]")
			else()
				set(value "\"${value}\"")
			endif()
			if(is_own)
				set(is_own "*")
			else()
				set(is_own " ")
			endif()

			set(nextValue "${is_own}${key}: ${value}")

			if(res)
				set(res "${res}\n ${nextValue}, ")	
			else()
				set(res " ${nextValue}, ")
			endif()
		endforeach()

		set(res "{\n${res}\n}")
		return_ref(res)
	endfunction()

	# prints the current object to the console
	proto_declarefunction(print)
	function(${print})
		#debug_message("printing object ${this}")
		obj_member_call(${this} "to_string" str )
		message("${str}")
	endfunction()
endfunction()







function(Functor)
	proto_declarefunction(call)
	function(${call})
		
	endfunction()
endfunction()




function(Configuration)
	this_inherit(CommandRunner)

	proto_declarefunction(AddConfigurationFilesRecurse )



	# create a field containing all configurations
	map_new()
  ans(configurations)
	this_set(configurations ${configurations})


	# recursively adds configuration files to the configuration object
	# starts with the given <path> and adds all coniguration files in <path> and its
	# paretn directories up to 
	function(${AddConfigurationFilesRecurse} path)
		# recursively add configuration files
		set(current_dir "${path}")
		while(true)
			get_filename_component(new_current_dir "${current_dir}" PATH)	
			# current dir is equal to new_current_dir when current_dir is root (recursion anchor)
			if("${new_current_dir}" STREQUAL "${current_dir}")
				break()
			endif()
			set(current_dir ${new_current_dir})
			# if cutil.config exists add it to configuration
			if(EXISTS "${current_dir}/cutil.config")
				string_normalize("${current_dir}/cutil.config")
				ans(name)
				obj_member_call(${this} AddConfigurationFile "${name}" "${current_dir}/cutil.config")
			endif()
		endwhile()
	endfunction()

	#  add a named configuration file to the configuration object
	# configuration files are searched in reverse order for 
	# configuration entries
	# 
	proto_declarefunction(AddConfigurationFile)
	function(${AddConfigurationFile} name config_file)
		set(config)
		message(DEBUG LEVEL 6 "Adding Configuration '${name}' @ ${config_file} ")
		map_navigate_set("this.configurations.${name}.file" "${config_file}")
		map_navigate_set("this.configurations.${name}.name" "${name}")
		obj_member_call(${this} Load)
	endfunction()

	# returns the configuration scope specified by SCOPE variable
	# if no SCOPE is specified  the most specialized scope is used
	# ie the last one added
	proto_declarefunction(GetScope)
	function(${GetScope} )
		this_import(configurations)
		cmake_parse_arguments("" "" "SCOPE" "" ${ARGN})
		set(config)
		if(NOT _SCOPE)
			map_keys(${configurations} )
			ans(keys)
			list_get( keys -2)
			ans(key)
			map_tryget(${configurations}  "${key}")
			ans(config)
		else()
			map_tryget(${configurations}  "${_SCOPE}")
			ans(config)
		endif()
		return_ref(config)
	endfunction()

	# set a configuration value in SCOPE. you can specify a navigation expression
	# if SCOPE is not specified the most specialized scope is used ie the last one
	# added
	# 
	proto_declarefunction(Set)
	function(${Set} navigation_expression value)	
		cmake_parse_arguments("" "" "SCOPE" "" ${ARGN})
		obj_member_call(${this} GetScope  SCOPE "${_SCOPE}")
		ans(config)
		if(NOT config)
			this_import(configurations)
			ref_print(${configurations})
			message(FATAL_ERROR "Configuration: could not find configuration scope '${_SCOPE}'")
		endif()

		map_get(${config}  "file")
		ans(file)
		map_get(${config}  "name")
		ans(name)
		if(EXISTS "${file}")
			file(READ "${file}" json)
			json_deserialize( ${json})
			ans(_config_object)
		endif()
		map_navigate_set("_config_object.${navigation_expression}" "${value}")
		
		map_navigate_set("configurations.${name}.config" ${_config_object})
		json_serialize( "${_config_object}" INDENTED)
		ans(json)
		file(WRITE "${file}" "${json}")
	endfunction()

	# get a configuration value from SCOPE if scope is not specified 
	# the most specialized scope is used
	proto_declarefunction(Get)
	function(${Get} navigation_expression)
		this_import(configurations)
		cmake_parse_arguments("" "" "SCOPE" "" ${ARGN})
		obj_member_call(${this} GetScope  SCOPE "${_SCOPE}")
		ans(config)
		if(NOT config)
			message(FATAL_ERROR "Configuration: could not find configuration scope")
		endif()

		map_keys(${configurations} )
		ans(keys)
		list(REVERSE keys)
		map_values(${configurations}  "${keys}" )
		ans(configs)
		if(NOT _SCOPE)
			list(GET keys 0 key)
			set(_SCOPE ${key})
		endif()
		set(found false)

		foreach(config ${configs})
			map_navigate(config_name "config.name")
			if(${found} OR ${config_name} STREQUAL "${_SCOPE}" )
				set(found true)
			endif()
			if(found)
				map_get(${config}  "file")
				ans(file)
				
				if(NOT EXISTS "${file}")
					return()
				endif()
				file(READ "${file}" json)
				json_deserialize( ${json})
				ans(_config_object)
				map_navigate(value "_config_object.${navigation_expression}")
				if(value)
					return_ref(value)
					break()
				endif()
			endif()
		endforeach()
		return()
	endfunction()

	proto_declarefunction(Save)
	function(${Save})
		map_keys(${configurations} )
		ans(keys)
		foreach(key ${keys})
			map_navigate(file "configurations.${key}.file")
			map_navigate(cfg "configurations.${key}.config")
			json_serialize( ${cfg} INDENTED)
			ans(json)
			file(WRITE ${file} "${json}")
		endforeach()
	endfunction()


	proto_declarefunction(Load)
	function(${Load})
		this_import(configurations)
		map_keys(${configurations} )
		ans(keys)
		set(configs)
		foreach(key ${keys})
			map_navigate(file "configurations.${key}.file")
			if(EXISTS  "${file}")
				file(READ ${file} json)
				json_deserialize( "${json}")
				ans(cfg)
				map_navigate_set("configurations.${key}.config" ${cfg})
				list(APPEND configs ${cfg})
			endif()
		endforeach()
		set(config)
		map_merge( ${configs})
		ans(config)
		this_set(configuration ${config})
		#ref_print(${config})
	endfunction()


	proto_declarefunction(GetCommand)
	function(${GetCommand})
		cmake_parse_arguments("" "--all;--json" "--scope" "" ${ARGN})
		obj_member_call(${this} Load)
		

		if(_--scope AND _--all)
			set(cfg)
			map_navigate(cfg "configurations.${_--scope}.config")
			if(cfg)
				ref_print(${cfg})
			else()
				message("no configuration found")
			endif()
			return()
		endif()

		if(_--all)
			if(configuration)
				ref_print(${configuration})
			else()
				message("no configuration found")
			endif()
			return()
		endif()

		if(_--scope)
			map_navigate(res "configurations.${_--scope}.config.${ARGN}")
			ref_print(${res})
		else()
			map_navigate(res "configuration.${ARGN}")
			ref_print(${res})
		endif()

	endfunction()


	proto_declarefunction(SetCommand)
	function(${SetCommand})
		cmake_parse_arguments("" "" "--scope" "" ${ARGN})
		set(scope)
		if( _--scope)
			set(scope SCOPE ${_--scope})
		endif()
		if(NOT _UNPARSED_ARGUMENTS)
			message("Configuration: not value to be set")
			return()
		endif()
		obj_member_call(${this} Set ${_UNPARSED_ARGUMENTS} ${scope})
	endfunction()

	proto_declarefunction(PrintScopes)
	function(${PrintScopes})
		map_keys(${configurations} )
		ans(keys)
		message("Current Config Scopes:")
		foreach(scope ${keys})
			message("  ${scope}")
		endforeach()
	endfunction()

	proto_declarefunction(SaveScope)
	function(${SaveScope} scope)
		map_tryget(${scope}  "file")
		ans(file)
		map_tryget(${scope}  config)
		ans(cfg)
		json_serialize( ${cfg})
		ans(res)
		file(WRITE "${file}" "${res}")
	endfunction()


	this_declare_call(__call__)
	function(${__call__})
		cmake_parse_arguments("" "" "--scope" "" ${ARGN})
		set(scope)
		if( _--scope)
			set(scope SCOPE ${_--scope})
		endif()

		obj_member_call(${this} GetScope  ${scope})
		ans(__scope)
		map_tryget(${__scope}  config)
		ans(cfg)
		if(NOT cfg)
			map_new()
    	ans(cfg)
			map_set(${__scope} config ${cfg})
		endif()

		if(NOT _UNPARSED_ARGUMENTS)

			set(cfg ${configuration})	
		else()
			list(LENGTH _UNPARSED_ARGUMENTS len)
			if(len EQUAL 1)
				set(cfg ${configuration})
			endif()
		endif()

		set(_UNPARSED_ARGUMENTS "cfg.${_UNPARSED_ARGUMENTS}")

		map_edit(${_UNPARSED_ARGUMENTS} --print)
		obj_member_call(${this} SaveScope ${__scope})
	endfunction()



#	obj_bind(bound_function ${this} ${Edit})
#	obj_member_call(${this} AddCommandHandler edit ${bound_function})

#	obj_bind(bound_function ${this} ${GetCommand})
#	obj_member_call(${this} AddCommandHandler get ${bound_function})

#	obj_bind(bound_function ${this} ${SetCommand})
#	obj_member_call(${this} AddCommandHandler set ${bound_function})

#	obj_bind(bound_function ${this} ${PrintScopes})
#	obj_member_call(${this} AddCommandHandler scopes ${bound_function})


endfunction()






function(http_headers_parse http_headers)
  http_regexes()
  string_semicolon_encode("${http_headers}")
  ans(http_headers)

  string(REGEX MATCHALL "${http_header_regex}" http_header_lines "${http_headers}")

  map_new()
  ans(result)
  foreach(header_line ${http_header_lines})
    string(REGEX REPLACE "${http_header_regex}" "\\1" header_key "${header_line}")
    string(REGEX REPLACE "${http_header_regex}" "\\2" header_value "${header_line}")
    string_semicolon_decode("${header_value}")
    ans(header_value)
    map_set(${result} "${header_key}" "${header_value}")
  endforeach()

  return_ref(result)
endfunction()







function(http_response_header_parse http_response)
  http_regexes()
  string_semicolon_encode("${http_response}")
  ans(http_response)

  string(REGEX REPLACE "${http_response_header_regex}" "\\1" response_line "${response}")
  string(REGEX REPLACE "${http_response_header_regex}" "\\5" response_headers "${response}")

  string(REGEX REPLACE "${http_response_line_regex}" "\\1" http_version "${response_line}" )
  string(REGEX REPLACE "${http_response_line_regex}" "\\2" http_status_code "${response_line}" )
  string(REGEX REPLACE "${http_response_line_regex}" "\\3" http_reason_phrase "${response_line}" )



  http_headers_parse("${response_headers}")
  ans(http_headers)


  map_new()
  ans(result)
  map_set(${result} "http_version" "${http_version}")
  map_set(${result} "http_status_code" "${http_status_code}")
  map_set(${result} "http_reason_phrase" "${http_reason_phrase}")
  map_set(${result} "http_headers" "${http_headers}")
  return_ref(result)

endfunction()




macro(check_host url)
 


# ensure that the package exists

  # expect webservice to be reachable
  http_get("${url}" "")
  ans(response)
  
  map_navigate(ok "response.code")
  if(NOT "${ok}" STREQUAL 200)
    message("Test inconclusive webserver unavailable")
    return()
  endif()

endmacro()




## --json only returns the content or nothing
function(http_get url content)
  set(args ${ARGN})
  list_extract_flag(args --json)
  ans(json_content)
  list_extract_flag(args --progress)
  ans(show_progress)
  if(show_progress)
    set(show_progress SHOW_PROGRESS)
  else()
    set(show_progress)
  endif()

  file_make_temporary(nothing)
  ans(target_path)

  obj("${content}")
  ans(content)

  uri_format("${url}" "${content}")
  ans(url)

  file(DOWNLOAD 
    "${url}" "${target_path}" 
    STATUS status 
    LOG http_log
    ${show_progress}
    TLS_VERIFY OFF 
    ${args}
  )

  http_last_response_parse("${http_log}")
  ans(result)

  list_extract(status client_status client_message)

  map_set(${result} client_status "${client_status}")
  map_set(${result} client_message "${client_message}")
  map_set(${result} request_url "${url}")

  fread("${target_path}")
  ans(content)
  map_set(${result} content "${content}")

  string(LENGTH "${content}" strlen)
  map_set(${result} content_length "${strlen}")
  map_set(${result} http_log "${http_log}")


  if(json_content)
    if(client_status)
      set(content)
    endif()
    json_deserialize("${content}")
    return_ans()
  endif()

  # 
  return_ref(result)
endfunction()




# content may be a file or structured data
function(http_put url content)
	message(DEBUG LEVEL 8 "http_put called for '${url}'")
	message_indent_push()
	set(tmpfile)
	
	data("${content}")
	ans(content)

	if(NOT EXISTS "${content}")
		map_isvalid("${content}")
		ans(ismap)

		if(ismap)
			json_serialize("${content}")
			ans(content)
		endif()
		file_make_temporary( "${content}")
		ans(tmpfile)
		set(content "${tmpfile}")
	endif()



	file(UPLOAD "${content}" "${url}" LOG log ${ARGN})
	if(tmpfile)
		file(REMOVE ${tmpfile})
	endif()

	http_response_parse("${log}")
	ans(res)
	message(DEBUG LEVEL 8 FORMAT "http_put returned response code: {res.code}" )
	message_indent_pop()
	return_ref(res)
endfunction()







function(http_request_header_parse http_request)
  http_regexes()

  string_semicolon_encode("${http_request}")
  ans(http_request)

  string(REGEX REPLACE "${http_request_header_regex}" "\\1" http_request_line "${http_request}")
  string(REGEX REPLACE "${http_request_header_regex}" "\\5" http_request_headers "${http_request}")

  string(REGEX REPLACE "${http_request_line_regex}" "\\1" http_method "${http_request_line}")
  string(REGEX REPLACE "${http_request_line_regex}" "\\2" http_request_uri "${http_request_line}")
  string(REGEX REPLACE "${http_request_line_regex}" "\\3" http_version "${http_request_line}")


  
  http_headers_parse("${http_request_headers}")
  ans(http_headers)

  map_new()
  ans(result)

  map_set(${result} http_method "${http_method}")
  map_set(${result} http_request_uri "${http_request_uri}")
  map_set(${result} http_version "${http_version}")
  map_set(${result} http_headers ${http_headers})

  return_ref(result)
endfunction()





## returns a response object for the last response in the specified http_log
## http_log is returned by cmake's file(DOWNLOAD|PUT LOG) function
## layout
## {
##   http_version:
##   http_status_code:
##   http_reason_phrase:
##   http_headers:{}
##   http_request:{
##      http_version:	
##      http_request_url:	
##      http_method:
##      http_headers:{}	
##   }
## }
function(http_last_response_parse http_log)
	string_semicolon_encode("${http_log}")
	ans(http_log)
	http_regexes()
	
	string(REGEX MATCHALL "(${http_request_header_regex})" requests "${http_log}")
	string(REGEX MATCHALL "(${http_response_header_regex})" responses "${http_log}")

	list_pop_back(requests)
	ans(request)
	http_request_header_parse("${request}")
	ans(request)

	list_pop_back(responses)
	ans(response)

	http_response_header_parse("${response}")
	ans(response)
	map_set(${response} http_request "${request}")
	return_ref(response)
endfunction()

## setup global variables to contain command_line_args
parse_command_line(command_line_args "${command_line_args}") # parses quoted command line args
map_set(global "command_line_args" ${command_line_args})
map_set(global "unused_command_line_args" ${command_line_args})
## todo... change this 
# setup oocmake config
map()
	kv(base_dir
		LABELS --oocmake-base-dir
		MIN 1 MAX 1
		DISPLAY_NAME "oo-cmake installation dir"
		DEFAULT "${CMAKE_CURRENT_LIST_DIR}"
		)
  kv(keep_temp 
    LABELS --keep-tmp --keep-temp -kt 
    MIN 0 MAX 0 
    DESCRIPTION "does not delete temporary files after") 
  kv(temp_dir
  	LABELS --temp-dir
  	MIN 1 MAX 1
  	DESCRIPTION "the directory used for temporary files"
  	DEFAULT "${oocmake_tmp_dir}/cutil/temp"
  	)
  kv(cache_dir
  	LABELS --cache-dir
  	MIN 1 MAX 1
  	DESCRIPTION "the directory used for caching data"
  	DEFAULT "${oocmake_tmp_dir}/cutil/cache"
  	)
  kv(bin_dir
    LABELS --bin-dir
    MIN 1 MAX 1
    DEFAULT "${CMAKE_CURRENT_LIST_DIR}/bin"
    )
end()
ans(oocmake_config_definition)
cd("${CMAKE_SOURCE_DIR}")
# setup config_function for oocmake
config_setup("oocmake_config" ${oocmake_config_definition})
## variables expected by cmake's find_package method
set(CMAKEPP_FOUND true)
set(CMAKEPP_VERSION_MAJOR "0")
set(CMAKEPP_VERSION_MINOR "0")
set(CMAKEPP_VERSION_PATCH "0")
set(CMAKEPP_VERSION "${CMAKEPP_VERSION_MAJOR}.${CMAKEPP_VERSION_MINOR}.${CMAKEPP_VERSION_PATCH}")
set(CMAKEPP_BASE_DIR "${oocmake_base_dir}")
set(CMAKEPP_BIN_DIR "${oocmake_base_dir}/bin")
set(CMAKEPP_TMP_DIR "${oocmake_tmp_dir}")

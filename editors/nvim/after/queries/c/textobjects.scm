; extends

(declaration
  declarator: (function_declarator)) @function.name

; function_definition [22, 0] - [26, 1]
;   declarator: function_declarator [22, 5] - [22, 21]
;     declarator: identifier [22, 5] - [22, 12]

(function_definition
  declarator: (function_declarator declarator: (identifier) @function.name))

; function_definition [13, 0] - [20, 1]
;   declarator: pointer_declarator [13, 5] - [13, 15]
;     declarator: function_declarator [13, 6] - [13, 15]
;       declarator: identifier [13, 6] - [13, 13]
;       parameters: parameter_list [13, 13] - [13, 15]

(function_definition
  declarator: (pointer_declarator declarator: (function_declarator declarator: (identifier) @function.name)))

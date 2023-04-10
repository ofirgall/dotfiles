; extends

;; Binary expression
(boolean_operator
  left: (_) @binary_expression.inner)
(boolean_operator
  right: (_) @binary_expression.inner)
(if_statement
  condition: (_) @binary_expression.inner)

;; Function name
(function_definition
  name: (_)? @function.name)

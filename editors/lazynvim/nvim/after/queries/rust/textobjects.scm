; extends

;; Binary expression
(binary_expression) @binary_expression.inner
(unary_expression) @binary_expression.inner

;; Function name
(function_item
  name: (_)? @function.name)

// prototype.jsonnet shows the prototypical structure of a file with hidden fields.
function(expr)
  std.foldl(
    function(acc, field) acc { [field]: 'hidden %s' % std.type(expr[field]) },
    std.objectFieldsAll(expr),
    {},
  )
  +
  std.foldl(
    function(acc, field) acc { [field]: std.type(expr[field]) },
    std.objectFields(expr),
    {},
  )

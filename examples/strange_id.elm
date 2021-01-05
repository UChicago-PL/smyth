type Bool = True () | False ()

id : Bool -> Bool
id b = b

to_id : (Bool -> Bool) -> (Bool -> Bool)
to_id f = ??

ugly_id : Bool -> Bool
ugly_id b = to_id id b

assert ugly_id True == True
assert ugly_id False == False

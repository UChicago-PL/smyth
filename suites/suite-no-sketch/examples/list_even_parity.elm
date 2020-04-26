specifyFunction evenParity
  [ ([], T ())
  , ([F ()], T ())
  , ([T ()], F ())
  , ([F (), F ()], T ())
  , ([F (), T ()], F ())
  , ([T (), F ()], F ())
  , ([T (), T ()], T ())
  ]

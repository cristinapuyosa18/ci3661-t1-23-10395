-- =====================================================================
--  CI-3661 — Tarea 1 (Haskell) — Septiembre–Diciembre 2026
--
--  Nombre: Cristina Puyosa
--  Carnet: 23-10395
--
--  Declaración de uso de herramientas de IA (obligatoria, ver enunciado):
--
-- =====================================================================
--  No cambies el nombre del módulo ni la lista de exportación, ni las
--  firmas de las funciones. Puedes agregar todas las funciones auxiliares
--  que quieras. El único import permitido es Data.Char.
-- =====================================================================
module Tarea1
  ( esPalindromo
  , mayorYMenor
  , leerHora
  , duracion
  , promedioSobreUmbral
  , movimientosCaballo
  , enDosSaltos
  , miMap
  , miFilter
  , miFoldl
  ) where

import Data.Char (isAlphaNum, isDigit, toLower, digitToInt)

-- =====================================================================
-- Parte A: recursión explícita.
-- Prohibido: map, filter, foldr, foldl, listas por comprensión, reverse,
-- maximum, minimum, all, any y cualquier otra función de orden superior.
-- =====================================================================

-- A1
transformar ::  String -> String
transformar [] = []
transformar (x:xs) = 
  if isAlphaNum x 
    then toLower x : transformar(xs)
    else transformar(xs)

inverso :: String -> String
inverso [] = []
inverso (x:xs) = inverso(xs) : x

esPalindromo :: String -> Bool
esPalindromo x = transformar x == inverso (transformar x)

-- A2
-- Explica aquí, en dos o tres líneas, por qué tu solución recorre la
-- lista una sola vez: porque La función procesa la lista mediante
-- recursión de cola sobre el patrón (x:xs), evaluando cada elemento x 
-- exactamente una vez en cada paso recursivo
--

mymAcarreo :: Ord a => (a, a) -> [a] -> (a, a)
mymAcarreo (a,b), [] = (a, b)
mymAcarreo (a,b) (x:xs) = 
  if x > a
    then  mymAcarreo (x, b) xs
  else if x < b 
    then  mymAcarreo (a, x) xs
  else mymAcarreo (a, b) xs

mayorYMenor :: Ord a => [a] -> Maybe (a, a)
mayorYMenor [] = Nothing
mayorYMenor (x:xs) = Just (mymAcarreo (x, x) xs)

-- A3
esDigito :: Char -> Bool
esDigito c = c >= '0' && c <= '9'

leerHora :: String -> Either String (Int, Int)
leerHora [a, b, ':', d, e] 
  | not (esDigito a && esDigito b && esDigito d && esDigito e) = Left "formato inválido"
  | (read [a, b] :: Int) >= 24 = Left "hora fuera de rango"
  | (read [d, e] :: Int) >= 60 = Left "minutos fuera de rango"
  | otherwise = Right ((read [a, b] :: Int), (read [d, e] :: Int))
leerHora _ = Left "formato inválido" 

duracion :: String -> String -> Either String Int
duracion str1 str2 = 
  case leerHora str1 of
    Left err1 -> Left err1
    Right (h1, m1) -> 
      case leerHora str2 of
        Left err2 -> Left err2
        Right (h2, m2) -> 
          if h2*60 + m2 >= h1*60 +m1 
            then Right ((h2 - h1)*60 + m2 - m1)
          else 
            Right ((24 + h2 - h1)*60 + m2 - m1)

-- =====================================================================
-- Parte B: orden superior.
-- Prohibido: recursión explícita (ninguna función de esta parte, ni sus
-- auxiliares, puede llamarse a sí misma).
-- =====================================================================

-- B1
promedioSobreUmbral :: Double -> [Double] -> Maybe Double
promedioSobreUmbral a s = 
  if n > 0 
    then Just ((foldr (+) 0 mayores)/ fromIntegral n)
  else 
    Nothing

  where
    mayores = [x | x <- s, x > a]
    n = length mayores

-- B2
movimientos :: [(Int, Int)]
movimientos = [(-2,-1), (-2,1), (-1,-2), (-1,2), (1,-2), (1,2), (2,-1), (2,1)]

movimientosCaballo :: (Int, Int) -> [(Int, Int)]
movimientosCaballo (p, q) =  [(a, b) | (a, b) <- (map (\(x, y) -> (x + p, y + q)) movimientos), a>0 && b> 0 && a<9 && b<9]

sinRepetidos :: Eq a => [a] -> [a]
sinRepetidos = foldr (\x acc -> if x `elem` acc then acc else x : acc) []

enDosSaltos :: (Int, Int) -> Int
enDosSaltos (p, q) = length ( sinRepetidos[ (a + c, b + d) | (a, b) <- movimientos, (c, d) <- unSalto, a+c>0 && b+d> 0 && a+c<9 && b+d<9])

  where
    unSalto = movimientosCaballo (p, q)

-- B3
miMap :: (a -> b) -> [a] -> [b]
miMap f arr = foldr (\x acc -> f x:acc) [] arr

miFilter :: (a -> Bool) -> [a] -> [a]
miFilter f arr = foldr (\x acc -> if f x then x:acc else acc) [] arr

miFoldl :: (b -> a -> b) -> b -> [a] -> b
miFoldl f z xs = foldr paso id xs z
  where
    paso x g acc = g (f acc x)

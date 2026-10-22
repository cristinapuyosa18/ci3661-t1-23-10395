# ci3661-t1-23-10395

**CI-3661 — Tarea 1 (Haskell) — Septiembre–Diciembre 2026**

- **Nombre:** Cristina Puyosa
- **Carnet:** 23-10395

## Contenido del repositorio

| Archivo | Descripción |
|---|---|
| `Tarea1.hs` | Solución de los problemas 1 a 6, con nombre, carnet y declaración de uso de IA en el encabezado. |
| `traza.pdf` | Problema 7: evaluación por sustitución, con los cuatro últimos dígitos de mi carnet. |
| `README.md` | Este archivo. |

## Cómo compilar y probar

Con GHC instalado (por ejemplo, mediante GHCup), desde la carpeta del repositorio:

```bash
# Compilar con advertencias
ghc -Wall -c Tarea1.hs

# Cargar en GHCi
ghci Tarea1.hs
```

Para correr las pruebas públicas, copiar `PruebasTarea1.hs` a la misma carpeta y ejecutar:

```bash
runghc PruebasTarea1.hs
```

---

## Parte A: recursión explícita, patrones, `Maybe` y `Either`

En esta parte no se usan `map`, `filter`, `foldr`, `foldl`, listas por comprensión, `reverse`, `maximum`, `minimum`, `all`, `any` ni otras funciones de orden superior. Todo se resuelve con recursión y pattern matching.

### A1. Palíndromos

- **`transformar :: String -> String`** (auxiliar). Normaliza una cadena para compararla: recorre los caracteres, descarta los que no son letra ni dígito (`isAlphaNum`) y pasa a minúscula los que conserva (`toLower`). Por ejemplo, `"Anita lava la tina"` se convierte en `"anitalavalatina"`.
- **`inverso :: String -> String`** (auxiliar). Invierte una cadena sin usar `reverse`: el inverso de `x:xs` es el inverso de `xs` seguido de `[x]`.
- **`esPalindromo :: String -> Bool`**. Normaliza la cadena con `transformar` y comprueba que sea igual a su inverso. La cadena vacía es palíndromo, porque su normalización es vacía y coincide con su inverso.

### A2. Mayor y menor en un solo recorrido

- **`mymAcarreo :: Ord a => (a, a) -> [a] -> (a, a)`** (auxiliar). Recibe el par `(mayor, menor)` acumulado hasta el momento y el resto de la lista. Para cada elemento `x`: si `x` es mayor que el mayor actual, lo reemplaza; si no, y `x` es menor que el menor actual, reemplaza el menor; si no, deja el par igual. Cuando la lista se acaba, devuelve el par.
- **`mayorYMenor :: Ord a => [a] -> Maybe (a, a)`**. Devuelve `Nothing` para la lista vacía. Si no, arranca el acumulador con el primer elemento como mayor y menor, `(x, x)`, y llama a `mymAcarreo` con el resto de la lista.

El recorrido es único porque el par `(mayor, menor)` viaja como acumulador y se actualiza junto en cada paso: cada elemento se consume una sola vez y no hace falta una segunda pasada para el mínimo.

### A3. Horas y duraciones

- **`esDigito :: Char -> Bool`** (auxiliar). Indica si un carácter está entre `'0'` y `'9'`.
- **`leerHora :: String -> Either String (Int, Int)`**. Interpreta una hora en formato `HH:MM`. El primer caso usa el patrón de lista `[a, b, ':', d, e]`, que solo acepta cadenas de exactamente cinco caracteres con los dos puntos en el centro. Luego, con guardias y en este orden:
  1. si alguno de los cuatro caracteres no es dígito, `Left "formato inválido"`;
  2. si la hora es mayor que 23, `Left "hora fuera de rango"`;
  3. si los minutos son mayores que 59, `Left "minutos fuera de rango"`;
  4. si no, `Right (hora, minutos)`.

  Cualquier cadena que no tenga la forma del patrón cae en el segundo caso y da `Left "formato inválido"`. Como la hora se revisa antes que los minutos, si ambas están fuera de rango se reporta la hora.
- **`duracion :: String -> String -> Either String Int`**. Calcula los minutos desde la primera hora hasta la segunda. Lee la primera hora con `leerHora` y, con `case`, si falla devuelve ese error; si no, lee la segunda y hace lo mismo, de modo que se reporta el error de la primera hora inválida. Con ambas horas válidas, pasa todo a minutos: si la segunda es mayor o igual que la primera, devuelve la diferencia; si es anterior, se entiende que es del día siguiente y se suman 24 horas antes de restar.

---

## Parte B: orden superior

En esta parte ninguna función ni auxiliar es recursiva. Se usan `map`, `foldr`, listas por comprensión y lambdas.

### B1. Promedio sobre un umbral

- **`promedioSobreUmbral :: Double -> [Double] -> Maybe Double`**. Promedia los elementos estrictamente mayores que el umbral, y devuelve `Nothing` si no hay ninguno. Lo hace con un solo `foldr` cuyo acumulador es la tupla `(suma, cantidad)`. Al terminar, si la cantidad es mayor que cero devuelve `Just (suma / cantidad)`, usando `fromIntegral` para convertir la cantidad de `Int` a `Double`.
- **`paso :: Double -> (Double, Int) -> (Double, Int)`** (auxiliar local, en el `where`). Es la función de paso del `foldr`: recibe un elemento `x` y el acumulador `(sumaAcc, cuenta)`. Si `x` supera el umbral, devuelve `(sumaAcc + x, cuenta + 1)`; si no, devuelve el acumulador sin cambios. La firma fija `cuenta` como `Int`, para evitar que GHC la resuelva por defecto como `Integer`.

### B2. Saltos de caballo

- **`movimientos :: [(Int, Int)]`** (auxiliar). Los ocho desplazamientos posibles de un caballo, escritos en orden lexicográfico (primero por el cambio de fila, luego por el de columna). Ese orden es lo que hace que las casillas salgan ordenadas sin tener que ordenar después.
- **`movimientosCaballo :: (Int, Int) -> [(Int, Int)]`**. Dada una casilla `(p, q)`, suma cada desplazamiento a esa casilla con `map` y, en la lista por comprensión, conserva solo las casillas cuyas coordenadas están entre 1 y 8. Como los desplazamientos ya están ordenados, el resultado queda en orden lexicográfico.
- **`sinRepetidos :: Eq a => [a] -> [a]`** (auxiliar). Elimina elementos repetidos con un `foldr`: el acumulador es la lista sin repetidos construida hasta el momento, y cada elemento se agrega al frente solo si todavía no está (`elem`). Conserva la última aparición de cada elemento, y el orden puede cambiar, lo cual no afecta cuando solo se necesita contar.
- **`enDosSaltos :: (Int, Int) -> Int`**. Cuenta las casillas distintas en las que puede quedar el caballo después de exactamente dos saltos. Parte de `unSalto`, que son las casillas válidas tras el primer salto; a cada una le aplica todos los desplazamientos del segundo salto y descarta las que quedan fuera del tablero. Después elimina repetidos con `sinRepetidos` y cuenta con `length`. La casilla de partida cuenta, porque el caballo puede ir y volver.
- **`unSalto`** (auxiliar local, en el `where`). Es `movimientosCaballo (p, q)`: las casillas alcanzables en el primer salto.

### B3. Todo es un `foldr`

- **`miMap :: (a -> b) -> [a] -> [b]`**. Es `map` hecho con `foldr`: el acumulador es la lista resultante de procesar el resto, y cada elemento se transforma con `f` y se agrega al frente.
- **`miFilter :: (a -> Bool) -> [a] -> [a]`**. Es `filter` hecho con `foldr`: cada elemento se agrega al frente del acumulador solo si cumple el predicado; si no, el acumulador queda igual.
- **`miFoldl :: (b -> a -> b) -> b -> [a] -> b`**. Se comporta como `foldl`, pero usando solo `foldr`. El plegado no construye el resultado directamente sino una función que, al recibir el valor inicial, lo calcula, y por eso el valor inicial `z` se le entrega al final: `foldr paso id xs z`.
- **`paso x g acc = g (f acc x)`** (auxiliar local, en el `where`). Es la función de paso de ese `foldr`. `g` es la función que representa el procesamiento del resto de la lista, y `acc` es el valor acumulado hasta ahora. `paso` aplica `f` al acumulador y al elemento `x`, y le pasa el resultado a `g`. El valor inicial del plegado es `id`, que devuelve el acumulador tal cual cuando ya no quedan elementos. Así los elementos se aplican de izquierda a derecha, aunque `foldr` recorra de derecha a izquierda.

---

## Problema 7: evaluación por sustitución

La traza está en `traza.pdf`. Usa los cuatro últimos dígitos de mi carnet, `d = [0, 3, 9, 5]`, e incluye la reducción de `foldr (-) 0 d`, la de `foldl (-) 0 d`, la de `miFoldl (-) 0 [0, 3]` con mi definición, y la explicación de por qué las dos primeras dan resultados distintos.

## Uso de asistentes de IA

La declaración completa está en el encabezado de `Tarea1.hs`. Usé Gemini y Claude para consultar dudas de sintaxis y de plegados, diagnosticar errores de compilación, verificar las restricciones de cada parte y redactar este README y algunos comentarios.

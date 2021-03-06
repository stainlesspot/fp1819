# Трета седмица

## За какво си говорихме?

1. Какво са функциите от по-висок ред и имат ли бъдеще у нас
2. lambda изрази
3. let изрази
4. Май стига толкова - събраха се доста неща

### [Още по материала](https://mitpress.mit.edu/sicp/full-text/book/book-Z-H-12.html#%_sec_1.3)

### 1. Какво е функция от по-висок ред и защо ни е?

Функциите от по-висок ред изпълняват поне едно от следните условия:
* Приемат функции като аргументи
* Връщат функция като резултат

#### В Scheme функциите са [first-class citizens](https://en.wikipedia.org/wiki/First-class_citizen).
Това ще рече, че спокойно можем да ги подаваме като аргументи на функции.
Спокойно можем да ги връщаме като резултат от функции.

Пример за функция, върната като резултат:
```Racket
; Искаме да сметнем a + |b|
(define (a-plus-mod-b a b)
  ((if (< b 0) - +) a b)
)
```

Предисловие към пример за функция, която приема други функции като аргументи:
Нека имаме следните три процедури:

```Racket
(define (sum-interval start end)
  (if (> start end)
      0
      (+ start (sum-interval (+ start 1) end))
  )
)

(define (cube x) (* x x x))

(define (sum-cubes start end)
  (if (> start end)
      0
      (+ (cube start) (sum-cubes (+ start 1) end))
  )
)

(define (pi-convergent start end)
  (if (> start end)
      0
      (+ (/ 1.0 (* 2 (+ a 2))) (pi-sum (+ start 4) end))
  )
)
```

Веднага могат да се видят няколко прилики. И трите функции:
* Терминират при едно и също условие `(> start end)`
* Терминират с един и същи резултат `0`
* Едното събираемо е някаква функция на `start` (например `(cube start)`)
* Другото събираемо е рекурсивно извикване на функцията
* В рекурсивното извикване обновяваме `start` като му прилагаме някаква функция (например `(+ start 4)`)

В какво се различават? Всяка от трите функции:
* Има различно име
* Прилага се различна функция на първото събираемо
* Прилага се различна функция, която обновява `start`

Оказва се, може да *обобщим* тези три функции в една, като параметризираме разликите между тях. Например:

```Racket
(define (sum start end term next)
  (if (> start end)
      0
      (+ (term start) (sum (next start) end term next))
  )
)
```

Wow wow wow. Малко обяснение какво се случи току що:

`sum` приема 4 аргумента:
* `start` и `end` вече ги знаем - началото и края на интервала, който искаме да сумираме
* `term` - едноаргументна функция, която прилагаме върху всяко събираемо
* `next` - едноаргументна функция, с която получаваме следващото число от интервала

Ако искаме да изразим горните три функции чрез нашата нова абстракция, можем да го направим така:
```Racket
(define (inc x) (+ x 1))

(define (sum-interval start end)
  (define (id x) x)
  (sum start end id inc))

(define (sum-cubes start end)
  (define (cube x) (* x x x))
  (sum start end cube inc))

(define (pi-sum start end)
  (define (term x) (/ 1.0 (* 2 (+ x 2))))
  (define (next x) (+ x 4))

  (sum start end term next))
```

Ако сега ни хрумне, че ни трябва произведение на числа в интервал, може
спокойно да направим функция `product`:

```Racket
(define (product start end term next)
  (if (> start end)
    1
    (* (term start) (product (next start) end term next))))
```

Можем да изразим пресмятането на факториел, чрез `product`:
```Racket
(define (factorial n)
  (define (id x) x)
  (define (inc x) (+ x 1))

  (product 1 n id inc))
```

Ако искаме да сметнем частното на числа в интервал, пък, ще трябва да напишем следното:
```Racket
(define (quotient-interval start end term next)
  (if (> start end)
    1
    (quotient start (quotient-interval (next start) end term next))))
```

Функциите `sum`, `product` и `quotient-interval` са много подобни.  
От тях можем да параметризираме още две неща, така че да си измислим още по-абстрактна функция, а именно:
* Стойността, с която терминират (при `sum` това е 0, а при другите две - 1)
* Функцията, с която се натрупва резултат (при `sum` - `+`, `product` - `*`, quotient-interval - `quotient`)

Получаваме следното atrocity:
```Racket
(define (accumulate operation null-value start end term next)
  (if (> start end)
    null-value
    (operation (term start) (accumulate operation null-value (next start) end term next))))
```

Чрез него можем да изразим всички функции, които сме дефинирали по-горе:
```Racket
(define (quotient-interval start end term next)
  (accumulate quotient 1 start end term next)
)

(define (product start end term next)
  (accumulate * 1 start end term next)
)

(define (factorial n)
  (define (id x) x)
  (define (inc x) (+ 1 x))

  (accumulate * 1 1 n id inc)
)
```

### 2. Ламбда изрази

Фунцкиите в Scheme (Racket) могат да се третират като обикновени данни, с които
програмите ни да работят.  

Чрез ламбда изрази могат да се създават функции. Общият синтаксис е следният:

```Racket
(lambda (arg1 arg2 ...) (body))
```

По този начин създаваме безименна функция, която може да извикаме веднага след дефиницията:
```Racket
((lambda (x n) (expt x n)) 2 3)
```

Тук дефинирахме анонимна функция, която приема 2 аргумента - x и n, и връща като
резултат x^n.  
С такава дефиниция можем да свържем и символ чрез `define`:
```Racket
(define pow (lambda (x n) (expt x n)))
```

От тук нататък pow е двуаргументна функция, която повдига първото число на степен второто.  

Дефинирането на функции чрез `define` всъщност е синтактична захар, зад която стои точно такова
присвояване:
```Racket
(define (pow x n)
  (expt x n)
)

; Това се превежда до
(define pow (lambda (x n) (expt x n)))
```

**lambda изразите ни позволяват да дефинираме функции "на момента"**

```Racket
;Вместо
(define (factorial n)
  (define (id x) x)
  (define (inc x) (+ x 1))

  (product 1 n id inc)
)

; Можем да направим това:
(define (factorial n)
  (product 1 n (lambda (x) x) (lambda (x) (+ x 1)))
)
```

Как да изразим композиция на две функции:
```Racket
(define (compose f g)
  (lambda (x) (f (g x)))
)
```

Така дефинирана, `compose` приема две функции за аргументи.  
Резултатът ѝ е композицията (сиреч - функция) на функциите, които дадем като аргументи.

```Racket
(define (square x) (* x x))
(define (dec x) (- x 1))

(define square-then-decrement (compose dec square))

(square-then-decrement 9) -> 80
```

Как да изразим повтаряне на функция n пъти:

```Racket
(define (repeat f n)
  (if (= n 1)
    f
    (compose f (repeat f (- n 1)))))

(define (inc x) (+ x 1))

(define plus-five (repeat inc 5))

(plus-five 2) -> 7
```

### 3. let изрази

let изразите ни позволяват да правим локални свързвания на имена със стойности.

Синтаксис (важи също за `let*` и `letrec`):
```Racket
(let 
  (
    (<name-1> <value-1>)
    (<name-2> <value-2>)
    ...
    (<name-n> <value-n>)
  )
  <body>
)
```

Ключовото при `let` е, че свързванията име-стойност се случват "едновременно". Това ще рече, че във `<value-2>` не мога да достъпя `<name-1>`.

`let*` решава този проблем, като позволява след като свържем символ със стойност, символът да е достъпен в следващите свързвания на `let*`.

Ето как, например, можем да намерим сбора на корените на квадратно уравнение по дадени коефициентите му:

```Racket
(define (solve-equation a b c)
  (let* ((d (- (square b) (* 4 a c)))
        (x1 (/ (- (- b) (sqrt d)) (* 2 a)))
        (x2 (/ (+ (- b) (sqrt d)) (* 2 a))))
    (+ x1 x2)
  )
)
```

Това не би сработило с `let`, защото в дефинициите на `x1` и `x2` използваме символа `d`, който сме дефинирали в `let*`.

### 4. Задачи от лекции

```Racket
((lambda (x) (x 12)) (lambda (y) (/ 108 y)))
```
Стъпка по стъпка:  
`(lambda (x) (x 12))` е функция.  
Аргументът х също е функция.  
Прилагаме функцията х на числото 12.  

`(lambda (y) (/ 108 y))` e функция.  
Приема число и дели 108 на него.  

Извикваме първата ламбда с аргумент - втората.  
`х` се превръща в `(lambda (y) (/ 108 y))`  
Резултатът от цялото нещо е  
`((lambda (y) (/ 108 y)) 12)`, което пък е `(/ 108 12)`.

***

```Racket
((lambda (x y) (x (y 9))) sqrt (lambda (y) (* y 9)))
```
`(lambda (x y) (x (y 9)))` е функция.  
Аргументите ѝ (`x` и `y`) също са функции.  

Извикваме тази ламбда веднага с първи аргумент `sqrt` и втори -
функция, която умножава число по 9.  

Тоест, `x` ще означава `sqrt`,  
 а `y` - `умножение на число по 9`.  
Тоест,  
`(x (y 9))` ->   
`(sqrt ((lambda (y) (* y 9)) 9))`->  
`(sqrt (* 9 9))`->  
`9`

***

```Racket
(let* ((x (lambda (x) (* x x x)))
       (y (x 3)))
   (* 2 (quotient y 9)))
```
Имаме локално свързан символ `x` със стойност функция, която повдига число на трета степен.  
След това имаме локално свързан символ `y`, който има стойност функцията `x` с аргумент 3, или 3 на 3-та степен (27).  

В тялото на `let*` изпълняваме `(* 2 (quotient 27 9)) -> 6`


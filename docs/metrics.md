# DORA Metrics

**Deployment Frequency**
* Jak często wdrażamy nowe zmiany na produkcję.
* **Zła wartość:** Zbyt rzadko (bo proces jest wolny lub powoduje problemy).

**Lead Time for Changes**
* Ile czasu mija od napisania kodu do wdrożenia go na produkcję.
* **Zła wartość:** Zbyt długo (generuje koszty, może zadziałać efekt kuli snieżnej-> coraz wiecej procesów w kolejcie i problemy sie nawarstwiają ).

**Mean Time to Recovery (MTTR)**
* Jak szybko naprawiamy awarię na produkcji.
* **Zła wartość:** Problemy z dostepnością, zwłaszcza w połączeniu ze słabym wskaznikiem niezawodnosci. 

**Change Failure Rate**
* Jaki procent wdrożeń kończy się błędem lub awarią.
* **Zła wartość:** Zbyt dużo wdrożeń psuje system.

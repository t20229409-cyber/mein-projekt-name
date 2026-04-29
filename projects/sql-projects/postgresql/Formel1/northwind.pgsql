-- Wer sind unsere Top 10 Kunden? 

SELECT 
	c.companyname,
	SUM(od.unitprice * od.quantity) AS gesamtsumme
FROM orders AS o
JOIN order_details AS od ON o.orderid = od.orderid
JOIN customers AS c ON o.customerid = c.customerid
GROUP BY c.companyname
ORDER BY gesamtsumme DESC
LIMIT 10;

-- Welche Produkte verkaufen sich am besten?
SELECT DISTINCT
    p.productname,
    SUM(od.quantity) OVER(PARTITION BY od.productid) AS gesamt_verkaufte_stueckzahl
FROM order_details AS od
JOIN products AS p ON p.productid = od.productid
ORDER BY gesamt_verkaufte_stueckzahl DESC
LIMIT 10;

-- Wie entwickelt sich der Umsatz pro Monat? 

SELECT
	TO_CHAR(o.orderdate, 'YYYY-MM') AS monat,
    ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS Umsatz
FROM orders AS o
JOIN order_details AS od ON od.orderid = o.orderid
GROUP BY Monat
ORDER BY Monat ASC;

-- Welche Regionen haben die schlechteste Performance?
SELECT 
    o.shipcountry AS region, 
    ROUND(SUM(od.unitprice * od.quantity * (1 - od.discount))::numeric, 2) AS gesamtumsatz,
    COUNT(o.orderid) AS anzahl_bestellungen
FROM orders AS o
JOIN order_details AS od ON o.orderid = od.orderid
GROUP BY o.shipcountry
ORDER BY gesamtumsatz ASC
LIMIT 5;

-- Wie hoch ist der durchschnittliche Bestellwert?
SELECT 
    ROUND(AVG(bestell_summen.total)::numeric, 2) AS durchschnittlicher_bestellwert
FROM (
    SELECT 
        orderid, 
        SUM(unitprice * quantity * (1 - discount)) AS total
    FROM order_details
    GROUP BY orderid
) AS bestell_summen;

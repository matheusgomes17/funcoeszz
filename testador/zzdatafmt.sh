#!/usr/bin/env bash

# Variáveis para comparar no resultado
ano=$(date '+%Y')
mes=$(date '+%m')
dia=$(date '+%d')
hoje=$dia/$mes/$ano


# Especial: parâmetros com espaços em branco, preciso do $protected
values=3
protected=2
tests=(
-f	'D M AA'		01/02/2003	t	"1 2 03"
-f	'DD MM AAAA'		01/02/2003	t	"01 02 2003"
-f	'D de MES de AAAA'	01/02/2003	t	"1 de fevereiro de 2003"

# Reconhecimento de data textual com conversão de idioma
--de	'19 de março de 2012'	''		t	'19. März 2012'
)
. _lib


# Reconhecimento de datas textuais: abreviado, completo, com/sem "de", maiúsculas/minúsculas
values=1
protected=1
tests=(
'31/jan/2013'				t	'31/01/2013'
'31-jan-2013'				t	'31/01/2013'
'31.jan.2013'				t	'31/01/2013'
'31 jan 2013'				t	'31/01/2013'

'31/janeiro/2013'			t	'31/01/2013'
'31-janeiro-2013'			t	'31/01/2013'
'31.janeiro.2013'			t	'31/01/2013'
'31 janeiro 2013'			t	'31/01/2013'

'31 DE JAN DE 2013'			t	'31/01/2013'
'31 de jan de 2013'			t	'31/01/2013'
'31 de jan 2013'			t	'31/01/2013'
'31 jan de 2013'			t	'31/01/2013'

'31 DE JANEIRO DE 2013'			t	'31/01/2013'
'31 de janeiro de 2013'			t	'31/01/2013'
'31 de janeiro 2013'			t	'31/01/2013'
'31 janeiro de 2013'			t	'31/01/2013'
)
. _lib



# Data textual passada em $1, $2, $3, etc (sem aspas)
values=5
protected=0
tests=(
31	de	jan	de	2013	t	31/01/2013
31	de	janeiro	de	2013	t	31/01/2013
)
. _lib



debug=0
values=4
protected=0

tests=(

# Erro: formato desconhecido (sem e com -f)
''	''	''	foo		t	"Erro: Data em formato desconhecido 'foo'"
''	''	''	001/02/2003	t	"Erro: Data em formato desconhecido '001/02/2003'"
''	''	''	01/002/2003	t	"Erro: Data em formato desconhecido '01/002/2003'"
''	''	''	01/02/20003	t	"Erro: Data em formato desconhecido '01/02/20003'"
''	''	''	aa/bb/cccc	t	"Erro: Data em formato desconhecido 'aa/bb/cccc'"
''	-f	AAAA	foo		t	"Erro: Data em formato desconhecido 'foo'"
''	-f	AA	001/02/2003	t	"Erro: Data em formato desconhecido '001/02/2003'"
''	-f	AA	01/002/2003	t	"Erro: Data em formato desconhecido '01/002/2003'"
''	-f	AA	01/02/20003	t	"Erro: Data em formato desconhecido '01/02/20003'"
''	-f	AA	aa/bb/cccc	t	"Erro: Data em formato desconhecido 'aa/bb/cccc'"

# Erro: formato conhecido, mas zztool testa_data falhou (sem e com -f)
''	''	''	99/99/9999	r	"Data inválida .*"
''	''	''	99/99/999	r	"Data inválida .*"
''	''	''	99/99/99	r	"Data inválida .*"
''	''	''	99/99/9		r	"Data inválida .*"
''	''	''	9/99/99		r	"Data inválida .*"
''	''	''	99/9/99		r	"Data inválida .*"
''	''	''	31/02/2003	r	"Data inválida .*"
''	-f	AA	99/99/9999	r	"Data inválida .*"
''	-f	AA	99/99/999	r	"Data inválida .*"
''	-f	AA	99/99/99	r	"Data inválida .*"
''	-f	AA	99/99/9		r	"Data inválida .*"
''	-f	AA	9/99/99		r	"Data inválida .*"
''	-f	AA	99/9/99		r	"Data inválida .*"
''	-f	AA	31/02/2003	r	"Data inválida .*"

# ok
''	''	''	05/08/1977	t	05/08/1977

# -f
''	-f	AAAA		01/02/2003	t	2003
''	-f	AAA		01/02/2003	t	033
''	-f	AA		01/02/2003	t	03
''	-f	A		01/02/2003	t	3
''	-f	ANO		01/02/2003	t	'dois mil e três'
''	-f	ANOA		01/02/2003	t	'dois mil e três3'
''	-f	AANO		01/02/2003	t	03NO
''	-f	MES		01/02/2003	t	fevereiro
''	-f	MESM		01/02/2003	t	fevereiro2
''	-f	MMES		01/02/2003	t	02ES
''	-f	MMMMMM		01/02/2003	t	fevfev
''	-f	MMMMM		01/02/2003	t	fev02
''	-f	MMMM		01/02/2003	t	fev2
''	-f	MMM		01/02/2003	t	fev
''	-f	MM		01/02/2003	t	02
''	-f	M		01/02/2003	t	2
''	-f	DDDD		01/02/2003	t	0101
''	-f	DDD		01/02/2003	t	011
''	-f	DD		01/02/2003	t	01
''	-f	D		01/02/2003	t	1
''	-f	DIA		01/02/2003	t	um
''	-f	DIAD		01/02/2003	t	um1
''	-f	DDIA		01/02/2003	t	01I3
''	-f	DIAA		01/02/2003	t	um3
''	-f	D/M/AA		01/02/2003	t	1/2/03
''	-f	DD/MM/AAAA	01/02/2003	t	01/02/2003
''	-f	D.de.MES.de.AA	01/02/2003	t	1.de.fevereiro.de.03
''	-f	A		11/12/2013	t	13
''	-f	M		11/12/2013	t	12
''	-f	D		11/12/2013	t	11
''	-f	A		11/12/2000	t	0

# nomes dos dias em Português
''	-f	DIA		01/01/2003	t	'um'
''	-f	DIA		02/01/2003	t	'dois'
''	-f	DIA		03/01/2003	t	'três'
''	-f	DIA		04/01/2003	t	'quatro'
''	-f	DIA		05/01/2003	t	'cinco'
''	-f	DIA		06/01/2003	t	'seis'
''	-f	DIA		07/01/2003	t	'sete'
''	-f	DIA		08/01/2003	t	'oito'
''	-f	DIA		09/01/2003	t	'nove'
''	-f	DIA		10/01/2003	t	'dez'
''	-f	DIA		11/01/2003	t	'onze'
''	-f	DIA		12/01/2003	t	'doze'
''	-f	DIA		13/01/2003	t	'treze'
''	-f	DIA		14/01/2003	t	'catorze'
''	-f	DIA		15/01/2003	t	'quinze'
''	-f	DIA		16/01/2003	t	'dezesseis'
''	-f	DIA		17/01/2003	t	'dezessete'
''	-f	DIA		18/01/2003	t	'dezoito'
''	-f	DIA		19/01/2003	t	'dezenove'
''	-f	DIA		20/01/2003	t	'vinte'
''	-f	DIA		21/01/2003	t	'vinte e um'
''	-f	DIA		22/01/2003	t	'vinte e dois'
''	-f	DIA		23/01/2003	t	'vinte e três'
''	-f	DIA		24/01/2003	t	'vinte e quatro'
''	-f	DIA		25/01/2003	t	'vinte e cinco'
''	-f	DIA		26/01/2003	t	'vinte e seis'
''	-f	DIA		27/01/2003	t	'vinte e sete'
''	-f	DIA		28/01/2003	t	'vinte e oito'
''	-f	DIA		29/01/2003	t	'vinte e nove'
''	-f	DIA		30/01/2003	t	'trinta'
''	-f	DIA		31/01/2003	t	'trinta e um'

# nomes dos anos em Português
''	-f	ANO		01/01/1000	t	'mil'
''	-f	ANO		01/01/1900	t	'mil e novecentos'
''	-f	ANO		01/01/1990	t	'mil novecentos e noventa'
''	-f	ANO		01/01/1999	t	'mil novecentos e noventa e nove'
''	-f	ANO		01/01/2000	t	'dois mil'
''	-f	ANO		01/01/2001	t	'dois mil e um'
''	-f	ANO		01/01/2010	t	'dois mil e dez'
''	-f	ANO		01/01/2123	t	'dois mil cento e vinte e três'

# nomes dos meses em Português
''	-f	MES	01/01/2000	t	janeiro
''	-f	MES	01/02/2000	t	fevereiro
''	-f	MES	01/03/2000	t	março
''	-f	MES	01/04/2000	t	abril
''	-f	MES	01/05/2000	t	maio
''	-f	MES	01/06/2000	t	junho
''	-f	MES	01/07/2000	t	julho
''	-f	MES	01/08/2000	t	agosto
''	-f	MES	01/09/2000	t	setembro
''	-f	MES	01/10/2000	t	outubro
''	-f	MES	01/11/2000	t	novembro
''	-f	MES	01/12/2000	t	dezembro
# Inglês
--en	-f	MES	01/01/2000	t	January
--en	-f	MES	01/02/2000	t	February
--en	-f	MES	01/03/2000	t	March
--en	-f	MES	01/04/2000	t	April
--en	-f	MES	01/05/2000	t	May
--en	-f	MES	01/06/2000	t	June
--en	-f	MES	01/07/2000	t	July
--en	-f	MES	01/08/2000	t	August
--en	-f	MES	01/09/2000	t	September
--en	-f	MES	01/10/2000	t	October
--en	-f	MES	01/11/2000	t	November
--en	-f	MES	01/12/2000	t	December
# Espanhol
--es	-f	MES	01/01/2000	t	Enero
--es	-f	MES	01/02/2000	t	Febrero
--es	-f	MES	01/03/2000	t	Marzo
--es	-f	MES	01/04/2000	t	Abril
--es	-f	MES	01/05/2000	t	Mayo
--es	-f	MES	01/06/2000	t	Junio
--es	-f	MES	01/07/2000	t	Julio
--es	-f	MES	01/08/2000	t	Agosto
--es	-f	MES	01/09/2000	t	Septiembre
--es	-f	MES	01/10/2000	t	Octubre
--es	-f	MES	01/11/2000	t	Noviembre
--es	-f	MES	01/12/2000	t	Diciembre
# Alemão
--de	-f	MES	01/01/2000	t	Januar
--de	-f	MES	01/02/2000	t	Februar
--de	-f	MES	01/03/2000	t	März
--de	-f	MES	01/04/2000	t	April
--de	-f	MES	01/05/2000	t	Mai
--de	-f	MES	01/06/2000	t	Juni
--de	-f	MES	01/07/2000	t	Juli
--de	-f	MES	01/08/2000	t	August
--de	-f	MES	01/09/2000	t	September
--de	-f	MES	01/10/2000	t	Oktober
--de	-f	MES	01/11/2000	t	November
--de	-f	MES	01/12/2000	t	Dezember
# Francês
--fr	-f	MES	01/01/2000	t	Janvier
--fr	-f	MES	01/02/2000	t	Février
--fr	-f	MES	01/03/2000	t	Mars
--fr	-f	MES	01/04/2000	t	Avril
--fr	-f	MES	01/05/2000	t	Mai
--fr	-f	MES	01/06/2000	t	Juin
--fr	-f	MES	01/07/2000	t	Juillet
--fr	-f	MES	01/08/2000	t	Août
--fr	-f	MES	01/09/2000	t	Septembre
--fr	-f	MES	01/10/2000	t	Octobre
--fr	-f	MES	01/11/2000	t	Novembre
--fr	-f	MES	01/12/2000	t	Décembre
# Italiano
--it	-f	MES	01/01/2000	t	Gennaio
--it	-f	MES	01/02/2000	t	Febbraio
--it	-f	MES	01/03/2000	t	Marzo
--it	-f	MES	01/04/2000	t	Aprile
--it	-f	MES	01/05/2000	t	Maggio
--it	-f	MES	01/06/2000	t	Giugno
--it	-f	MES	01/07/2000	t	Luglio
--it	-f	MES	01/08/2000	t	Agosto
--it	-f	MES	01/09/2000	t	Settembre
--it	-f	MES	01/10/2000	t	Ottobre
--it	-f	MES	01/11/2000	t	Novembre
--it	-f	MES	01/12/2000	t	Dicembre

# nomes dos meses, abreviado, em Português
''	-f	MMM	01/01/2000	t	'jan'
''	-f	MMM	01/02/2000	t	'fev'
''	-f	MMM	01/03/2000	t	'mar'
''	-f	MMM	01/04/2000	t	'abr'
''	-f	MMM	01/05/2000	t	'mai'
''	-f	MMM	01/06/2000	t	'jun'
''	-f	MMM	01/07/2000	t	'jul'
''	-f	MMM	01/08/2000	t	'ago'
''	-f	MMM	01/09/2000	t	'set'
''	-f	MMM	01/10/2000	t	'out'
''	-f	MMM	01/11/2000	t	'nov'
''	-f	MMM	01/12/2000	t	'dez'
# Inglês
--en	-f	MMM	01/01/2000	t	'Jan'
--en	-f	MMM	01/02/2000	t	'Feb'
--en	-f	MMM	01/03/2000	t	'Mar'
--en	-f	MMM	01/04/2000	t	'Apr'
--en	-f	MMM	01/05/2000	t	'May'
--en	-f	MMM	01/06/2000	t	'Jun'
--en	-f	MMM	01/07/2000	t	'Jul'
--en	-f	MMM	01/08/2000	t	'Aug'
--en	-f	MMM	01/09/2000	t	'Sep'
--en	-f	MMM	01/10/2000	t	'Oct'
--en	-f	MMM	01/11/2000	t	'Nov'
--en	-f	MMM	01/12/2000	t	'Dec'
# Espanhol
--es	-f	MMM	01/01/2000	t	Ene
--es	-f	MMM	01/02/2000	t	Feb
--es	-f	MMM	01/03/2000	t	Mar
--es	-f	MMM	01/04/2000	t	Abr
--es	-f	MMM	01/05/2000	t	May
--es	-f	MMM	01/06/2000	t	Jun
--es	-f	MMM	01/07/2000	t	Jul
--es	-f	MMM	01/08/2000	t	Ago
--es	-f	MMM	01/09/2000	t	Sep
--es	-f	MMM	01/10/2000	t	Oct
--es	-f	MMM	01/11/2000	t	Nov
--es	-f	MMM	01/12/2000	t	Dic
# Alemão
--de	-f	MMM	01/01/2000	t	Jan
--de	-f	MMM	01/02/2000	t	Feb
--de	-f	MMM	01/03/2000	t	Mär
--de	-f	MMM	01/04/2000	t	Apr
--de	-f	MMM	01/05/2000	t	Mai
--de	-f	MMM	01/06/2000	t	Jun
--de	-f	MMM	01/07/2000	t	Jul
--de	-f	MMM	01/08/2000	t	Aug
--de	-f	MMM	01/09/2000	t	Sep
--de	-f	MMM	01/10/2000	t	Okt
--de	-f	MMM	01/11/2000	t	Nov
--de	-f	MMM	01/12/2000	t	Dez
# Francês
--fr	-f	MMM	01/01/2000	t	Jan
--fr	-f	MMM	01/02/2000	t	Fév
--fr	-f	MMM	01/03/2000	t	Mar
--fr	-f	MMM	01/04/2000	t	Avr
--fr	-f	MMM	01/05/2000	t	Mai
--fr	-f	MMM	01/06/2000	t	Jui
--fr	-f	MMM	01/07/2000	t	Jui
--fr	-f	MMM	01/08/2000	t	Aoû
--fr	-f	MMM	01/09/2000	t	Sep
--fr	-f	MMM	01/10/2000	t	Oct
--fr	-f	MMM	01/11/2000	t	Nov
--fr	-f	MMM	01/12/2000	t	Déc
# Italiano
--it	-f	MMM	01/01/2000	t	Gen
--it	-f	MMM	01/02/2000	t	Feb
--it	-f	MMM	01/03/2000	t	Mar
--it	-f	MMM	01/04/2000	t	Apr
--it	-f	MMM	01/05/2000	t	Mag
--it	-f	MMM	01/06/2000	t	Giu
--it	-f	MMM	01/07/2000	t	Lug
--it	-f	MMM	01/08/2000	t	Ago
--it	-f	MMM	01/09/2000	t	Set
--it	-f	MMM	01/10/2000	t	Ott
--it	-f	MMM	01/11/2000	t	Nov
--it	-f	MMM	01/12/2000	t	Dic

# formato padrão de cada idioma
--pt	31/03/2000	''	''	t	'31 de março de 2000'
--ptt	31/03/2000	''	''	t	'trinta e um de março de dois mil'
--en	31/03/2000	''	''	t	'March, 31 2000'
--it	31/03/2000	''	''	t	'31 da Marzo 2000'
--es	31/03/2000	''	''	t	'31 de Marzo de 2000'
--de	31/03/2000	''	''	t	'31. März 2000'
--fr	31/03/2000	''	''	t	'Le 31 Mars 2000'

# ano 4 dígitos, sem alterações
''	''	''	01/02/0003	t	01/02/0003
''	''	''	01/02/0033	t	01/02/0033
''	''	''	01/02/0333	t	01/02/0333
''	''	''	01/02/3333	t	01/02/3333

# ano 3 dígitos, completa com um zero
''	''	''	01/02/003	t	01/02/0003
''	''	''	01/02/033	t	01/02/0033
''	''	''	01/02/333	t	01/02/0333

# ano 2 dígitos, pode ser 19.. ou 20..
''	''	''	01/02/40	t	01/02/1940
''	''	''	01/02/41	t	01/02/1941
''	''	''	01/02/50	t	01/02/1950
''	''	''	01/02/60	t	01/02/1960
''	''	''	01/02/70	t	01/02/1970
''	''	''	01/02/80	t	01/02/1980
''	''	''	01/02/90	t	01/02/1990
''	''	''	01/02/99	t	01/02/1999
''	''	''	01/02/00	t	01/02/2000
''	''	''	01/02/01	t	01/02/2001
''	''	''	01/02/10	t	01/02/2010
''	''	''	01/02/20	t	01/02/2020
''	''	''	01/02/30	t	01/02/2030
''	''	''	01/02/38	t	01/02/2038
''	''	''	01/02/39	t	01/02/2039

# ano 1 dígito, é sempre 200.
''	''	''	01/02/0		t	01/02/2000
''	''	''	01/02/1		t	01/02/2001
''	''	''	01/02/2		t	01/02/2002
''	''	''	01/02/3		t	01/02/2003
''	''	''	01/02/4		t	01/02/2004
''	''	''	01/02/5		t	01/02/2005
''	''	''	01/02/6		t	01/02/2006
''	''	''	01/02/7		t	01/02/2007
''	''	''	01/02/8		t	01/02/2008
''	''	''	01/02/9		t	01/02/2009

# mês 1 dígito
''	''	''	01/1/2003	t	01/01/2003
''	''	''	01/2/2003	t	01/02/2003
''	''	''	01/3/2003	t	01/03/2003
''	''	''	01/4/2003	t	01/04/2003
''	''	''	01/5/2003	t	01/05/2003
''	''	''	01/6/2003	t	01/06/2003
''	''	''	01/7/2003	t	01/07/2003
''	''	''	01/8/2003	t	01/08/2003
''	''	''	01/9/2003	t	01/09/2003

# dia 1 dígito
''	''	''	1/02/2003	t	01/02/2003
''	''	''	2/02/2003	t	02/02/2003
''	''	''	3/02/2003	t	03/02/2003
''	''	''	4/02/2003	t	04/02/2003
''	''	''	5/02/2003	t	05/02/2003
''	''	''	6/02/2003	t	06/02/2003
''	''	''	7/02/2003	t	07/02/2003
''	''	''	8/02/2003	t	08/02/2003
''	''	''	9/02/2003	t	09/02/2003

# faltando zeros, misturado
''	''	''	1/2/2003	t	01/02/2003
''	''	''	1/2/003		t	01/02/0003
''	''	''	1/2/03		t	01/02/2003
''	''	''	1/2/3		t	01/02/2003
''	''	''	1/2/73		t	01/02/1973
''	''	''	1/02/003	t	01/02/0003
''	''	''	1/02/03		t	01/02/2003
''	''	''	1/02/3		t	01/02/2003
''	''	''	1/02/73		t	01/02/1973
''	''	''	01/2/003	t	01/02/0003
''	''	''	01/2/03		t	01/02/2003
''	''	''	01/2/3		t	01/02/2003
''	''	''	01/2/73		t	01/02/1973

# Apelidos
''	''	''	hoje		t	$hoje

# formato iso
''	''	''	1977-08-05	t	05/08/1977

# delimitador diferente
''	''	''	05-08-1977	t	05/08/1977
''	''	''	05-08-77	t	05/08/1977
''	''	''	05-08-7		t	05/08/2007
''	''	''	5-08-1977	t	05/08/1977
''	''	''	5-08-77		t	05/08/1977
''	''	''	5-08-7		t	05/08/2007
''	''	''	05-8-1977	t	05/08/1977
''	''	''	05-8-77		t	05/08/1977
''	''	''	05-8-7		t	05/08/2007
''	''	''	5-8-1977	t	05/08/1977
''	''	''	5-8-77		t	05/08/1977
''	''	''	5-8-7		t	05/08/2007
#
''	''	''	05.08.1977	t	05/08/1977
''	''	''	05.08.77	t	05/08/1977
''	''	''	05.08.7		t	05/08/2007
''	''	''	5.08.1977	t	05/08/1977
''	''	''	5.08.77		t	05/08/1977
''	''	''	5.08.7		t	05/08/2007
''	''	''	05.8.1977	t	05/08/1977
''	''	''	05.8.77		t	05/08/1977
''	''	''	05.8.7		t	05/08/2007
''	''	''	5.8.1977	t	05/08/1977
''	''	''	5.8.77		t	05/08/1977
''	''	''	5.8.7		t	05/08/2007

# sem delimitador
''	''	''	05081977	t	05/08/1977
''	''	''	050877		t	05/08/1977
''	''	''	050817		t	05/08/2017

# dia e mês
''	''	''	05/06		t	05/06/$ano
''	''	''	05/6		t	05/06/$ano
''	''	''	5/06		t	05/06/$ano
''	''	''	5/6		t	05/06/$ano

### Daqui pra baixo ainda não foi implementado
### (e ainda não sei se deve ser)

# # só dia
# ''	''	''	1		t	01/$mes/$ano
# ''	''	''	2		t	02/$mes/$ano
# ''	''	''	3		t	03/$mes/$ano
# ''	''	''	4		t	04/$mes/$ano
# ''	''	''	5		t	05/$mes/$ano
# ''	''	''	6		t	06/$mes/$ano
# ''	''	''	7		t	07/$mes/$ano
# ''	''	''	8		t	08/$mes/$ano
# ''	''	''	9		t	09/$mes/$ano
# ''	''	''	01		t	01/$mes/$ano
# ''	''	''	02		t	02/$mes/$ano
# ''	''	''	03		t	03/$mes/$ano
# ''	''	''	04		t	04/$mes/$ano
# ''	''	''	05		t	05/$mes/$ano
# ''	''	''	06		t	06/$mes/$ano
# ''	''	''	07		t	07/$mes/$ano
# ''	''	''	08		t	08/$mes/$ano
# ''	''	''	09		t	09/$mes/$ano
# ''	''	''	10		t	10/$mes/$ano
# ''	''	''	11		t	11/$mes/$ano
# ''	''	''	12		t	12/$mes/$ano
# ''	''	''	13		t	13/$mes/$ano
# ''	''	''	14		t	14/$mes/$ano
# ''	''	''	15		t	15/$mes/$ano
# ''	''	''	16		t	16/$mes/$ano
# ''	''	''	17		t	17/$mes/$ano
# ''	''	''	18		t	18/$mes/$ano
# ''	''	''	19		t	19/$mes/$ano
# ''	''	''	20		t	20/$mes/$ano
# ''	''	''	21		t	21/$mes/$ano
# ''	''	''	22		t	22/$mes/$ano
# ''	''	''	23		t	23/$mes/$ano
# ''	''	''	24		t	24/$mes/$ano
# ''	''	''	25		t	25/$mes/$ano
# ''	''	''	26		t	26/$mes/$ano
# ''	''	''	27		t	27/$mes/$ano
# ''	''	''	28		t	28/$mes/$ano
# ''	''	''	29		t	29/$mes/$ano
# ''	''	''	30		t	30/$mes/$ano
# ''	''	''	31		t	31/$mes/$ano
#
# # só mês e ano
# ''	''	''	08/1977		t	$dia/08/1977
# ''	''	''	8/1977		t	$dia/08/1977
#
# # só o ano
# ''	''	''	1977		t	$dia/$mes/1977

)
. _lib
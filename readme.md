# CIDR IP Range 계산기 

<br/>

## CIDR 계산식

CIDR은 ip 부분과 접두어 부분이 합쳐저 IP 범위를 나타내는 표기형식 이다. <br/>
10.0.0.0/24 는 10.0.0.0 ~ 10.0.0.255 즉 2^(32 - 24) - 1 만큼 IP를 사용할 수 있다. <br/><br/>

### 접두어 길이로 자르기
ip는 이진수를 10진수로 나타냈으므로 각 자리는 8자리 이진수를 가진다. 따라서 접두어를 8씩 나누어야 한다. <br/>
a.b.c.d/e 라는 ip가 주어졌다고 가정한다. <br/>
접두어의 길이를 e라고 했을 경우 아래와 같은 범위로 자른다. <br/>
````
1) 24 <= e <= 32 
2) 16 <= e <= 23 
3) 8 <= e <= 15 
4) 0 <= e <= 7 
````
그리고 시작 ip를 찾기 위해 계산변수 x를 사용한다
````
x = 2^(max(e) - e)
````
<br/>
1) 의 경우 마지막 자리의 시작 번호를 D라고 했을 경우 아래와 같이 계산된다

````
D = d - (d % x)
시작 IP : a.b.c.D
````
<br/>
마지막 IP는 아래와 같이 계산된다

````
D + x - 1
끝 IP : a.b.c.(D + x - 1)
````
<br/>
2) 의 경우 1과 같이 계산하며 D대신 C를 쓴다. 마지막 자리 ip 범위는 0 ~ 255이다. 

````
C + x - 1
끝 IP : a.b.(C + x - 1).0 ~ 255
````
<br/><br/>

## 스크립트 사용하기
````
# 모듈 Import
Import-Module -Name D:\PowerShell\PowerShell\cidr\cidr.psm1 -Force
# 초기화
$cidr = getCidrCalculator
# ip 대입
$cidr.setCidr("10.0.0.1/30")
````
이후 Class내의 함수를 사용하여 여러 데이터 추출.<br/>

## 비교
CIDR 계산기를 제공해주는 사이트와 비교
![Alt text](https://github.com/chupark/PowerShell/blob/master/cidr/img/1.png "Optional title")

<br/>

![Alt text](https://github.com/chupark/PowerShell/blob/master/cidr/img/2.png "Optional title")
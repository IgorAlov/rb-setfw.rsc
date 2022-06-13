
## Описание:

**Привет друг**, данный скриптик написан для удобства поддержания большого парка 
Mikrotik RouterBoard с определенными вресиями прошивок. Ну скажем иногда
нужно что то обноавить, а может быть даже даунгрейдить, и чтобы не парится
с ручным скачиванием прошивок для нужной архитекторы достаточно просто 
загрузиить и запустить скрипт. Он все сделает за вас.

## Как приминить?
На самом деле все очень просто:
* Качаете скрипта `git clone https://github.com/IgorAlov/rb-setfw.rsc` в директорию вашего `www` сервера;
* Выполняете команду на закачку скрипта:
   * пример если вы используете на вашем сервере https + basic auth:
      * `/tool fetch url=https://ваш-www-сервер/rb-setfw.rsc mode=https ascii=yes keep-result=yes user="user" password="password"`
   * пример дял простого http:
      * `/tool fetch url=https://ваш-www-сервер/rb-setfw.rsc mode=http ascii=yes keep-result=yes`
* Импортируем скаченый скрипт `/impot rb-setfw.rsc`
* Ну и все, наслаждаемся результатом.
* Скрипт, после выполнения, должен сам удалится с устройства. Если не хотите, то можно закоментировать строку `/file remove`

## Для тех кто использует RouterOS API:
скрипт можно установить на роутер, и запустить примерно такой конструкцией на PHP:
```
...
microtik_import_apiscript($API,"rb-setfw.rsc");
...

function	microtik_import_apiscript($API,$script_name)
	{
	if(!isset($API)||$script_name=="") return false;

	$script_id="";
	$arrID=$API->comm("/tool/fetch", 
		array(
			"mode"					=> "https",
        	"check-certificate"  => "no",
        	"url"						=> "https://ваш-www-сервер/".$script_name,
			"dst-path"				=> $script_name,
			"keep-result"			=> "yes",
			"ascii"					=> "yes",
			"user"					=> "username",
			"password"				=> "password"
			));
	sleep(2);
	$arrID=$API->comm("/file/getall", 
		array(
			".proplist"=> ".id",
			"?name"		=> $script_name
			));
	$script_id=(isset($arrID["0"][".id"]))?$arrID["0"][".id"]:"";
	if($script_id!="")
		{
		$arrID=$API->comm("/import", 
	  		array(
				"file-name"		=> $script_name
				));
	
		$arrID=$API->comm("/file/remove", 
			array(
		  	".id"		=> $script_id
		  	));
		}
   return true;
	}
```

### Описание переменных:

* `debug  "false"` **->** может принимать значения ( true | false ), собвтенно нужен для отладки.

* `rqvers "6.49.1"` **->** **Важная переменная**, в ней содержится необходимая версия прошики RouterOS, которую нужно поставить на роутер.

### Служебные переменные (которые трогать не рекомендуется):
* `rbvers` и `rbarch` **->** Текущая версия прошивки и архитектура routerBoard (определятся автоматом).

* `rburl` **->** Путь откуда будет скачиваться файл (автоматом, с сайта mikrotik.com)

* `rbact` **->** Записывается значение параметра, обновлять, даунгрейдит и ничего не делать.



## Описание:

**Привет друг**, данный скриптик написан для удобства поддержания большого парка 
Mikrotik RouterBoard с определенными вресиями прошивок. Ну скажем иногда
нужно что то обновить, а может быть даже даунгрейдить, и чтобы не парится
с ручным скачиванием прошивок для нужной архитектуры достаточно просто 
загрузиить и запустить скрипт. Он все сделает за вас. Совместимость скрипта проверена на ROSv6 и ROSv7 (в том числе и "переезд" между 6 и 7 версиями).

## Как применить?
На самом деле все очень просто:
* Вариант загрузки и выполнения скрипта прямо из репозитория (если Вас устраивают значения по умолчнию, и роутер имеет доступ к сети интернет) для этого Вам нужно выполнить две команды:
```bash
/tool fetch url=https://raw.githubusercontent.com/IgorAlov/rb-setfw.rsc/main/rb-setfw.rsc mode=https ascii=yes keep-result=yes 
/import rb-setfw.rsc
```
* Альтернативный вариант использования на локальном сервере:
	* Загружаете скрипт `git clone https://github.com/IgorAlov/rb-setfw.rsc` в директорию вашего `www` сервера;
	* Выполняете команду на загрузку скрипта:
   	* пример, если Вы используете на вашем сервере https + basic auth:
      	* `/tool fetch url=https://ваш-www-сервер/rb-setfw.rsc mode=https ascii=yes keep-result=yes user="user" password="password"`
   	* пример, для простого http:
      	* `/tool fetch url=https://ваш-www-сервер/rb-setfw.rsc mode=http ascii=yes keep-result=yes`
	* Импортируем загруженный скрипт `/import rb-setfw.rsc`
	* Ну и все, наслаждаемся результатом.
	* Скрипт, после выполнения, должен сам удалится с устройства, однако если Вы хотите его отсавить, то можно закомментировать последню строчку в скрипте `/file remove`

## Для тех кто использует RouterOS API:
Используя API, можно автоматизироваь загрузку скрипта на роутер и запуск его. Как можно сделать это на языке PHP показано ниже:
```php
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
полная версия скрипта представлена в файле `example_import_script.php` для запуска, которого так же требуется php class, который может быть загружен из [репоизтория](https://github.com/IgorAlov/routeros-api).
### Описание переменных:

* `debug  "false"` **->** может принимать значения ( true | false ), собвтенно нужен для отладки.

* `rqvers "6.49.6"` **->** **Важная переменная**, в ней содержится необходимая версия прошики RouterOS, которую нужно поставить на роутер.

### Служебные переменные (заполняются автоматически):
* `rbvers` и `rbarch` **->** Текущая версия прошивки и архитектура RouterBoard;

* `rburl` **->** Путь откуда будет скачиваться файл (берется с официального сайта mikrotik.com);

* `rbact` **->** Записывается значение параметра "action" => обновлять, даунгрейдить или ничего не делать скрипту по резулятатм сравнения версий прошивок RouterOS.

## Ошибки и контрибьюция
Если Вы нашли баг - создате `issue` я постарюсь решить его. Так же если Вы хотите стать частью проекта, то wellcome).
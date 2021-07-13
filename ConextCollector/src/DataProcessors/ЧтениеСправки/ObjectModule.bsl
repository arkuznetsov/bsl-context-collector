////////////////////////////////////////////////////////////////////////////////////
// За основу проекта взяты разработки Валерия Агеева (@awa) (проект MetaRead)
// и Виктории Дорохиной (@bambr1975).
////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных
Перем Кавычка;

#Область КлючевыеСлова

// Для русского языка
Перем Ключевое_ВариантСинтаксиса;
Перем Ключевое_Синтаксис;
Перем Ключевое_Параметры;
Перем Ключевое_ОписаниеВарианта;
Перем Ключевое_Описание;
Перем Ключевое_ВозвращаемоеЗначение;
Перем Ключевое_Тип;
Перем Ключевое_Доступность;
Перем Ключевое_Пример;
// Для английского языка
Перем КлючевоеА_ВариантСинтаксиса;
Перем КлючевоеА_Синтаксис;
Перем КлючевоеА_Параметры;
Перем КлючевоеА_ОписаниеВарианта;
Перем КлючевоеА_Описание;
Перем КлючевоеА_ВозвращаемоеЗначение;
Перем КлючевоеА_Тип;
Перем КлючевоеА_Доступность;
Перем КлючевоеА_Пример;

#КонецОбласти

#КонецОбласти

#Область ПрограммныйИнтерфейс

Функция ПрочитатьДеревоСправкиИзКниги(Знач ПутьДоКниги) Экспорт
	
	Компонента = НовыйОбъектКомпоненты();
	
	ФайлКниги = Новый Файл(ПутьДоКниги);
	Если Не ФайлКниги.Существует() Тогда
		ОбщийМодуль.СообщитьПользователю("Файл книги со справкой не существует");
		Возврат Неопределено;
	КонецЕсли;
	
	Содержание = НовоеСодержание();
	
	Если Не Компонента.Открыть(ПутьДоКниги, Истина) Тогда
		ОбщийМодуль.СообщитьПользователю("Не удалось открыть файл """
			+ ПутьДоКниги + """ (файл не является контейнером 1Cv8 или файл открыт другой программой)");
		Возврат Неопределено;
	КонецЕсли;
	
	// Читаем PackBlock
	Если Не Компонента.СуществуетФайл("PackBlock") Тогда
		ОбщийМодуль.СообщитьПользователю("В контейнере """ + ПутьДоКниги + """ не найден файл ""PackBlock""");
		Возврат Неопределено;
	КонецЕсли;
	
	ВременныйФайл = ПолучитьИмяВременногоФайла();
	ВременныйКаталог = ПолучитьИмяВременногоФайла();
	
	Компонента.ПрочитатьВоВнешнийФайл("PackBlock", ВременныйФайл);
	
	Файл = Новый Файл(ВременныйФайл);
	Если Файл.Размер() = 0 Тогда
		ОбщийМодуль.УдалитьВременныйФайл(ВременныйФайл);
		Возврат Неопределено;
	КонецЕсли;
	
	ЧтениеЗИП = Новый ЧтениеZipФайла(ВременныйФайл);
	Если ЧтениеЗИП.Элементы.Количество() = 0 Тогда
		ОбщийМодуль.СообщитьПользователю("В архиве PackBlock не найдено ни одного файла");
		ЧтениеЗИП = Неопределено;
		ОбщийМодуль.УдалитьВременныйФайл(ВременныйФайл);
		Возврат Неопределено;
	КонецЕсли;
	Если ЧтениеЗИП.Элементы.Количество() > 1 Тогда
		ОбщийМодуль.СообщитьПользователю("В архиве PackBlock больше одного файла");
		ЧтениеЗИП = Неопределено;
		ОбщийМодуль.УдалитьВременныйФайл(ВременныйФайл);
		Возврат Неопределено;
	КонецЕсли;
	
	ЭлементЗИП = ЧтениеЗИП.Элементы[0];
	ЧтениеЗИП.Извлечь(ЭлементЗИП, ВременныйКаталог);
	ЭлементЗИП = Неопределено;
	
	ПутьКАрхивуКниги = ВременныйКаталог + "\" + "0";
	
	ТекстовыйДокумент = Новый ТекстовыйДокумент();
	ТекстовыйДокумент.Прочитать(ПутьКАрхивуКниги);
	ДеревоСправки = НовоеДеревоИзСправки(ТекстовыйДокумент);
	ОбщийМодуль.УдалитьВременныйФайл(ВременныйФайл);
	ТекстовыйДокумент = Неопределено;
	
	ОбработатьДеревоСправки(ДеревоСправки, Содержание);
	
	Возврат Содержание;
	
КонецФункции

Функция ПрочитатьОпределение(Знач ПутьДоФайла) Экспорт
	
	Файл = Новый Файл(ПутьДоФайла);
	Если Не Файл.Существует() Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат ОпределениеИзФайла(ПутьДоФайла);
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция НовыйОбъектКомпоненты()
	ВременныйФайл = Новый Файл(ПолучитьИмяВременногоФайла());
	ИмяФайлаКомпоненты = ВременныйФайл.Путь + "Cv8cf2.dll";
	МакетКомпоненты = ПолучитьОбщийМакет("v8cf2");
	МакетКомпоненты.Записать(ИмяФайлаКомпоненты);
	Успех = ПодключитьВнешнююКомпоненту(ИмяФайлаКомпоненты, "ЧтениеСправки", ТипВнешнейКомпоненты.COM);
	Если Не Успех Тогда
		Возврат Неопределено;
	КонецЕсли;
	Компонента = Новый("AddIn.ЧтениеСправки.Cv8cf2");
	Возврат Компонента;
КонецФункции

Функция НовоеСодержание()
	Содержание = Новый ДеревоЗначений();
	Содержание.Колонки.Добавить("Имя", Новый ОписаниеТипов("Строка"));
	Содержание.Колонки.Добавить("Путь", Новый ОписаниеТипов("Строка"));
	Содержание.Колонки.Добавить("ПутьДляПоиска", Новый ОписаниеТипов("Строка"));
	Содержание.Колонки.Добавить("Статус", Новый ОписаниеТипов("Число"));
	Возврат Содержание;
КонецФункции

Процедура ОбработатьДеревоСправки(Дерево, Содержание)
	
	СтрокиДерева = Дерево.Строки[0].Строки;
	КоличествоЭлементов = + СтрокиДерева[0].Значение;
	
	СоответствиеНомеровСтрок = Новый Соответствие;
	Для Ин = 1 По КоличествоЭлементов Цикл
		СоответствиеНомеровСтрок.Вставить(+ СтрокиДерева[Ин].Строки[0].Значение, Ин);
	КонецЦикла;
	
	Для Ин = 1 По КоличествоЭлементов Цикл
		СтрокаДерева = СтрокиДерева[Ин].Строки;
		Родитель = + СтрокаДерева[1].Значение;
		Если Родитель = 0 Тогда
			Стоп = 1;
			РекурсивноеДобавлениеСтрокВСодержание(СтрокиДерева, + СтрокаДерева[0].Значение, Содержание,
				Содержание, КоличествоЭлементов, СоответствиеНомеровСтрок);
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

Процедура РекурсивноеДобавлениеСтрокВСодержание(СтрокиДерева, Номер, СтрокаРодителя,
		Содержание, КоличествоЭлементов, СоответствиеНомеровСтрок)
	
	Номер = СоответствиеНомеровСтрок[Номер];
	СтрокаДерева = СтрокиДерева[Номер].Строки;
	КоличествоПодчиненных = + СтрокаДерева[2].Значение;
	
	НоваяСтрока = СтрокаРодителя.Строки.Добавить();
	Попытка
		НоваяСтрока.Имя = ПрочитатьСтрокуНаТекущемЯзыке(СтрокаДерева[КоличествоПодчиненных + 3].Строки[2]);
	Исключение
		ОбщийМодуль.СообщитьПользователю("Не удалось обработать в " + СтрокаРодителя.Имя);
	КонецПопытки;
	НоваяСтрока.Путь = СтрокаДерева[КоличествоПодчиненных + 3].Строки[3].Значение;
	НоваяСтрока.ПутьДляПоиска = НРег(НоваяСтрока.Путь);
	Если Лев(НоваяСтрока.ПутьДляПоиска, 1) = "/" Тогда
		НоваяСтрока.ПутьДляПоиска = Сред(НоваяСтрока.ПутьДляПоиска, 2);
	КонецЕсли;
	НоваяСтрока.Статус = ?(КоличествоПодчиненных = 0, 1, 0);
	Для Ин = 1 По КоличествоПодчиненных Цикл
		РекурсивноеДобавлениеСтрокВСодержание(СтрокиДерева, + СтрокаДерева[Ин + 2].Значение, НоваяСтрока,
			Содержание, КоличествоЭлементов, СоответствиеНомеровСтрок);
	КонецЦикла;
	
КонецПроцедуры

Функция ПрочитатьСтрокуНаТекущемЯзыке(СтрокаДерева)
	СтрокаНаНейтральномЯзыке = "";
	Для Ин = 2 По СтрокаДерева.Строки.Количество() - 1 Цикл
		ТекСтрока = СтрокаДерева.Строки[Ин];
		ТекущийЯзык = ТекСтрока.Строки[0].Значение;
		Если ТекущийЯзык = "ru" Тогда
			Возврат ТекСтрока.Строки[1].Значение;
		ИначеЕсли ТекущийЯзык = "#" Тогда
			СтрокаНаНейтральномЯзыке = ТекСтрока.Строки[1].Значение;
		КонецЕсли;
	КонецЦикла;
	Если Не ПустаяСтрока(СтрокаНаНейтральномЯзыке) Тогда
		Возврат СтрокаНаНейтральномЯзыке;
	КонецЕсли;
	Возврат СтрокаДерева.Строки[2].Строки[1].Значение;
КонецФункции

Функция НовоеДеревоИзСправки(ТекстовыйДокумент)
	Дерево = Новый ДеревоЗначений;
	Дерево.Колонки.Добавить("Значение");
	ТекущаяСтрока = Дерево.Строки.Добавить();
	
	// Режимы парсера
	Режим_ОжиданиеЗначения = 0;
	Режим_ВводСтроки = 1;
	Режим_ВводЗначения = 2;
	Режим_ОжиданиеРазделителя = 3;
	
	Режим = Режим_ОжиданиеЗначения;
	ВременноеЗначение = "";
	
	Для НомерСтрокиВходнойСтроки = 1 По ТекстовыйДокумент.КоличествоСтрок() Цикл
		ТекущаяВходнаяСтрока = ТекстовыйДокумент.ПолучитьСтроку(НомерСтрокиВходнойСтроки) + Символы.ПС;
		Пока Не ПустаяСтрока(ТекущаяВходнаяСтрока) Цикл
			Если Режим = Режим_ОжиданиеЗначения Тогда
				ТекущаяВходнаяСтрока = СокрЛП(ТекущаяВходнаяСтрока);
				ОчереднойСимвол = Лев(ТекущаяВходнаяСтрока, 1);
				ТекущаяВходнаяСтрока = Сред(ТекущаяВходнаяСтрока, 2);
				Если ОчереднойСимвол = "{" Тогда
					ТекущаяСтрока = ТекущаяСтрока.Строки.Добавить();
					ИначеЕсли ОчереднойСимвол = Кавычка Тогда
						ВременноеЗначение = "";
					Режим = Режим_ВводСтроки;
				ИначеЕсли ОчереднойСимвол = "," Тогда
					ТекущаяСтрока = ТекущаяСтрока.Родитель.Строки.Добавить();
				ИначеЕсли ОчереднойСимвол = "}" Тогда
					ТекущаяСтрока = ТекущаяСтрока.Родитель;
					Режим = Режим_ОжиданиеРазделителя;
				Иначе
					ВременноеЗначение = ОчереднойСимвол;
					Режим = Режим_ВводЗначения;
				КонецЕсли;
			ИначеЕсли Режим = Режим_ВводСтроки Тогда
				Позиция = СтрНайти(ТекущаяВходнаяСтрока, Кавычка);
				Если Позиция = 0 Тогда
					ВременноеЗначение = ВременноеЗначение + ТекущаяВходнаяСтрока;
					ТекущаяВходнаяСтрока = "";
				Иначе
					ВременноеЗначение = ВременноеЗначение + Лев(ТекущаяВходнаяСтрока, Позиция - 1);
					ТекущаяВходнаяСтрока = Сред(ТекущаяВходнаяСтрока, Позиция + 1);
					Если Лев(ТекущаяВходнаяСтрока, 1) = Кавычка Тогда
						ВременноеЗначение = ВременноеЗначение + Кавычка;
						ТекущаяВходнаяСтрока = Сред(ТекущаяВходнаяСтрока, 2);
					Иначе
						ТекущаяСтрока.Значение = ВременноеЗначение;
						Режим = Режим_ОжиданиеРазделителя;
					КонецЕсли;
				КонецЕсли;
			ИначеЕсли Режим = Режим_ВводЗначения Тогда
				Позиция1 = СтрНайти(ТекущаяВходнаяСтрока, ",");
				Позиция2 = СтрНайти(ТекущаяВходнаяСтрока, "}");
				Если Позиция1 = 0 Тогда
					Если Позиция2 = 0 Тогда
						ВременноеЗначение = ВременноеЗначение + ТекущаяВходнаяСтрока;
						ТекущаяВходнаяСтрока = "";
					Иначе
						ВременноеЗначение = ВременноеЗначение + Лев(ТекущаяВходнаяСтрока, Позиция2 - 1);
						ТекущаяВходнаяСтрока = Сред(ТекущаяВходнаяСтрока, Позиция2 + 1);
						ТекущаяСтрока.Значение = ВременноеЗначение;
						ТекущаяСтрока = ТекущаяСтрока.Родитель;
						Режим = Режим_ОжиданиеРазделителя;
					КонецЕсли;
				Иначе
					Если Позиция2 = 0 Тогда
						ВременноеЗначение = ВременноеЗначение + Лев(ТекущаяВходнаяСтрока, Позиция1 - 1);
						ТекущаяВходнаяСтрока = Сред(ТекущаяВходнаяСтрока, Позиция1 + 1);
						ТекущаяСтрока.Значение = ВременноеЗначение;
						ТекущаяСтрока = ТекущаяСтрока.Родитель.Строки.Добавить();
						Режим = Режим_ОжиданиеЗначения;
					Иначе
						Если Позиция1 < Позиция2 Тогда
							ВременноеЗначение = ВременноеЗначение + Лев(ТекущаяВходнаяСтрока, Позиция1 - 1);
							ТекущаяВходнаяСтрока = Сред(ТекущаяВходнаяСтрока, Позиция1 + 1);
							ТекущаяСтрока.Значение = ВременноеЗначение;
							ТекущаяСтрока = ТекущаяСтрока.Родитель.Строки.Добавить();
							Режим = Режим_ОжиданиеЗначения;
						Иначе
							ВременноеЗначение = ВременноеЗначение + Лев(ТекущаяВходнаяСтрока, Позиция2 - 1);
							ТекущаяВходнаяСтрока = Сред(ТекущаяВходнаяСтрока, Позиция2 + 1);
							ТекущаяСтрока.Значение = ВременноеЗначение;
							ТекущаяСтрока = ТекущаяСтрока.Родитель;
							Режим = Режим_ОжиданиеРазделителя;
						КонецЕсли;
					КонецЕсли;
				КонецЕсли;
			ИначеЕсли Режим = Режим_ОжиданиеРазделителя Тогда
				ТекущаяВходнаяСтрока = СокрЛ(ТекущаяВходнаяСтрока);
				ОчереднойСимвол = Лев(ТекущаяВходнаяСтрока, 1);
				ТекущаяВходнаяСтрока = Сред(ТекущаяВходнаяСтрока, 2);
				Если ОчереднойСимвол = "," Тогда
					ТекущаяСтрока = ТекущаяСтрока.Родитель.Строки.Добавить();
					Режим = Режим_ОжиданиеЗначения;
				ИначеЕсли ОчереднойСимвол = "}" Тогда
					ТекущаяСтрока = ТекущаяСтрока.Родитель;
				Иначе
					ТекстОшибки = СтрШаблон("Недопустимый символ %1 (Код символа %2) в режиме ожидания разделителя",
							ОчереднойСимвол, КодСимвола(ОчереднойСимвол));
					ОбщийМодуль.СообщитьПользователю(ТекстОшибки);
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	Возврат Дерево;
КонецФункции

#Область ЧтениеСправкиHTML

Функция ОпределениеИзФайла(ПутьДоФайла)
	
	ЧтениеХТМЛ = Новый ЧтениеHTML;
	ПостроительДОМ = Новый ПостроительDOM;
	ЧтениеХТМЛ.ОткрытьФайл(ПутьДоФайла, "UTF-8");
	ДокументХТМЛ = ПостроительДОМ.Прочитать(ЧтениеХТМЛ);
	
	ШаблонОпределения = НовыйШаблонОпределения();
	
	Содержимое = ДокументХТМЛ.ПолучитьЭлементыПоИмени("body")[0];
	
	Для Каждого Элемент Из Содержимое.ДочерниеУзлы Цикл
		
		ТекстУзла = Элемент.ТекстовоеСодержимое;
		ТекстДляПоиска = СокрЛП(ТекстУзла);
		
		Если ЭтоТегЗаголовкаСтраницы(Элемент) Тогда
			
			ПараИдентификаторов = ПрочитатьИдентификаторыЭлементаИзСтроки(Элемент.ТекстовоеСодержимое);
			ШаблонОпределения.Идентификатор = ПараИдентификаторов; 
			
		ИначеЕсли ЭтоТегЗаголовка(Элемент) Тогда
			
			Пара = ПрочитатьИдентификаторыЭлементаИзСтроки(Элемент.ТекстовоеСодержимое);
			ШаблонОпределения.Заголовок = ТекстУзла;
			ШаблонОпределения.Наименование = Пара;
			
		ИначеЕсли ЭтоКлючевоеСлово(ТекстДляПоиска, Ключевое_Синтаксис)
			Или ЭтоКлючевоеСлово(ТекстДляПоиска, КлючевоеА_Синтаксис) Тогда
			
			Синтакс = Новый Структура;
			ШаблонОпределения.Перегрузки.Добавить(Синтакс);
			Синтакс.Вставить("Конструктор", Элемент.СледующийСоседний.ТекстовоеСодержимое);
			
			Синтакс.Конструктор = СтрЗаменить(Синтакс.Конструктор, "<", "");
			Синтакс.Конструктор = СтрЗаменить(Синтакс.Конструктор, ">", "");
			
			Синтакс.Вставить("Параметры", Новый Массив);
			Синтакс.Вставить("Описание", Новый Массив);
			Синтакс.Вставить("Вариант", "");
			
			Предыдущий = Элемент.ПредыдущийСоседний;
			Если ЭтоКлючевоеСлово(Предыдущий.ТекстовоеСодержимое, Ключевое_ВариантСинтаксиса)
				Или ЭтоКлючевоеСлово(Предыдущий.ТекстовоеСодержимое, КлючевоеА_ВариантСинтаксиса) Тогда
				
				Синтакс.Вариант = СокрЛП(СтрЗаменить(Предыдущий.ТекстовоеСодержимое, Ключевое_ВариантСинтаксиса, ""));
				Синтакс.Вариант = СокрЛП(СтрЗаменить(Синтакс.Вариант, КлючевоеА_ВариантСинтаксиса, ""));
				
			КонецЕсли;
			
			Если ПустаяСтрока(Синтакс.Вариант) Тогда
				Синтакс.Вариант = "Основной";
			КонецЕсли;
			
		ИначеЕсли ЭтоКлючевоеСлово(ТекстДляПоиска, Ключевое_Параметры)
			Или ЭтоКлючевоеСлово(ТекстДляПоиска, КлючевоеА_Параметры) Тогда
			
			ОбработатьПараметры(Синтакс, Элемент);
			
		ИначеЕсли ЭтоГлава(Элемент) И ЭтоКлючевоеСлово(ТекстДляПоиска, "Значения") Тогда
			
			ШаблонОпределения.ЕстьЗначения = Истина;
			
		ИначеЕсли ЭтоКлючевоеСлово(ТекстДляПоиска, Ключевое_ОписаниеВарианта)
			Или ЭтоКлючевоеСлово(ТекстДляПоиска, КлючевоеА_ОписаниеВарианта) Тогда
			
			Следующий = Элемент.СледующийСоседний;
			Пока Не ЭтоСледующаяГлава(Следующий) Цикл
				
				ВалидноеПредставление = ЗначениеИзУзла(Следующий);
				Синтакс.Описание.Добавить(ВалидноеПредставление);
				
				Следующий = Следующий.СледующийСоседний;
			КонецЦикла;
			
		ИначеЕсли ЭтоКлючевоеСлово(ТекстДляПоиска, Ключевое_Описание)
			Или ЭтоКлючевоеСлово(ТекстДляПоиска, КлючевоеА_Описание) Тогда
			
			Следующий = Элемент.СледующийСоседний;
			Пока Не ЭтоСледующаяГлава(Следующий) Цикл
				
				ВалидноеПредставление = ЗначениеИзУзла(Следующий);
				ШаблонОпределения.Описание.Добавить(ВалидноеПредставление);
				
				Следующий = Следующий.СледующийСоседний;
			КонецЦикла;
			
		ИначеЕсли ЭтоКлючевоеСлово(ТекстДляПоиска, Ключевое_ВозвращаемоеЗначение)
			Или ЭтоКлючевоеСлово(ТекстДляПоиска, КлючевоеА_ВозвращаемоеЗначение) Тогда
			
			СледующийЭлемент = Элемент.СледующийСоседний;
			Пока СледующийЭлемент <> Неопределено И СокрЛП(СледующийЭлемент.ТекстовоеСодержимое) <> "." Цикл
				
				Если СледующийЭлемент.ИмяУзла = "a" Тогда
					ОписаниеТипа = Новый Структура;
					ОписаниеТипа.Вставить("Имя", СледующийЭлемент.ТекстовоеСодержимое);
					ОписаниеТипа.Вставить("Ссылка", СледующийЭлемент.Гиперссылка);
					
					ШаблонОпределения.ВозвращаемоеЗначение.Типы.Добавить(ОписаниеТипа);
				КонецЕсли;
				
				СледующийЭлемент = СледующийЭлемент.СледующийСоседний;
			КонецЦикла;
			
		ИначеЕсли ЭтоКлючевоеСлово(ТекстДляПоиска, Ключевое_Доступность)
			Или ЭтоКлючевоеСлово(ТекстДляПоиска, КлючевоеА_Доступность) Тогда
			
			Следующий = Элемент.СледующийСоседний;
			Если Следующий.ИмяУзла = "#text" Тогда
				Значение = Следующий.ТекстовоеСодержимое;
				Массив = СтрРазделить(Значение, ",");
				Для Каждого ЭлементДоступности Из Массив Цикл
					мЗначение = нРег(СокрЛП(ЭлементДоступности));
					Если Прав(мЗначение, 1) = "." Тогда
						мЗначение = Лев(мЗначение, СтрДлина(мЗначение) - 1);
					КонецЕсли;
					ШаблонОпределения.Доступность.Добавить(мЗначение);
				КонецЦикла;
			КонецЕсли;
			
		ИначеЕсли ЭтоКлючевоеСлово(ТекстДляПоиска, Ключевое_Пример)
			Или ЭтоКлючевоеСлово(ТекстДляПоиска, КлючевоеА_Пример) Тогда
			
			Следующий = Элемент.СледующийСоседний;
			Пока Не ЭтоСледующаяГлава(Следующий) Цикл
				
				Если Следующий.ИмяУзла = "hr" Тогда
					Прервать;
				КонецЕсли;
				
				ВалидноеПредставление = ЗначениеИзУзла(Следующий);
				ШаблонОпределения.Пример.Добавить(ВалидноеПредставление);
				
				Следующий = Следующий.СледующийСоседний;
			КонецЦикла;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат ШаблонОпределения;
	
КонецФункции

Процедура ОбработатьПараметры(Синтакс, ТекЭлемент)
	
	Параметр = Неопределено;
	
	ЭлементТочка = Неопределено;
	МассивОписание = Новый Массив;
	
	СледующийЭлемент = ТекЭлемент.СледующийСоседний;
	Пока СледующийЭлемент <> Неопределено Цикл
		
		Текст = СокрЛП(СледующийЭлемент.ТекстовоеСодержимое);
		ТекстДляПоиска = СокрЛП(Текст);
		ИмяУзла = СледующийЭлемент.ИмяУзла;
		
		Если ЭтоКлючевоеСлово(Текст, Ключевое_ВозвращаемоеЗначение)
			Или ЭтоКлючевоеСлово(Текст, КлючевоеА_ВозвращаемоеЗначение)
			Или ЭтоКлючевоеСлово(Текст, Ключевое_ОписаниеВарианта)
			Или ЭтоКлючевоеСлово(Текст, КлючевоеА_ОписаниеВарианта) Тогда
			Возврат;
		ИначеЕсли СтрНайти(Текст, "<") > 0 И СтрНайти(Текст, ">") > 0 И Лев(ТекстДляПоиска, 1) = "<" Тогда
			
			ЭлементТочка = Неопределено;
			
			Параметр = Новый Структура;
			Синтакс.Параметры.Добавить(Параметр);
			
			Параметр.Вставить("Типы", Новый Массив);
			Параметр.Вставить("Представление", Текст);
			Параметр.Вставить("Обязательный", Не СтрНайти(Текст, "необязательный") > 0);
			Параметр.Вставить("Описание", Новый Массив);
			
		ИначеЕсли
			ЭтоКлючевоеСлово(Текст, Ключевое_Тип) Или ЭтоКлючевоеСлово(Текст, КлючевоеА_Тип) Тогда
			//СтрНайти(Текст, Ключевое_Тип) > 0 Тогда
			
			ВремТекст = СокрЛП(Текст);
			Если Прав(ВремТекст, 1) = "." Тогда
				
				ОстатокОтСтроки = Лев(ВремТекст, СтрДлина(ВремТекст) - 1);
				ОстатокОтСтроки = СтрЗаменить(ОстатокОтСтроки, Ключевое_Тип, "");
				ОстатокОтСтроки = СтрЗаменить(ОстатокОтСтроки, КлючевоеА_Тип, "");
				ОстатокОтСтроки = СокрЛП(ОстатокОтСтроки);
				
				Массив = СтрРазделить(ОстатокОтСтроки, ",");
				Для Каждого ЭлементТипа Из Массив Цикл
					
					ОписаниеТипа = Новый Структура;
					ОписаниеТипа.Вставить("Имя", ЭлементТипа);
					ОписаниеТипа.Вставить("Ссылка", "#");
					
					Параметр.Типы.Добавить(ОписаниеТипа);
					
				КонецЦикла;
				
			Иначе
				
				СледующийЭлемент = СледующийЭлемент.СледующийСоседний;
				Пока СледующийЭлемент <> Неопределено И СокрЛП(СледующийЭлемент.ТекстовоеСодержимое) <> "." Цикл
					
					Если СледующийЭлемент.ИмяУзла = "a" Тогда
						ОписаниеТипа = Новый Структура;
						ОписаниеТипа.Вставить("Имя", СледующийЭлемент.ТекстовоеСодержимое);
						ОписаниеТипа.Вставить("Ссылка", СледующийЭлемент.Гиперссылка);
						
						Параметр.Типы.Добавить(ОписаниеТипа);
					КонецЕсли;
					
					СледующийЭлемент = СледующийЭлемент.СледующийСоседний;
				КонецЦикла;
				
				Если СледующийЭлемент <> Неопределено И СокрЛП(СледующийЭлемент.ТекстовоеСодержимое) = "." Тогда
					
					// с точки до след. рубрики
					Следующий = СледующийЭлемент.СледующийСоседний;
					Пока Не ЭтоСледующаяГлава(Следующий) И Не ЭтоСледующаяРубрика(Следующий) Цикл
						
						ВалидноеПредставление = ЗначениеИзУзла(Следующий);
						Параметр.Описание.Добавить(ВалидноеПредставление);
						
						Следующий = Следующий.СледующийСоседний;
					КонецЦикла;
					
					СледующийЭлемент = Следующий.ПредыдущийСоседний;
				КонецЕсли;
				
			КонецЕсли;
			
		КонецЕсли;
		
		Если СледующийЭлемент = Неопределено Тогда
			Прервать;
		КонецЕсли;
		
		СледующийЭлемент = СледующийЭлемент.СледующийСоседний;
		
	КонецЦикла;
	
	Возврат;
	
КонецПроцедуры

Функция НовыйШаблонОпределения()
	Определение = Новый Структура;
	Определение.Вставить("Заголовок", "");
	Определение.Вставить("Идентификатор", Неопределено);
	Определение.Вставить("Наименование", Неопределено); // только для методов
	Определение.Вставить("Перегрузки", Новый Массив);
	Определение.Вставить("Описание", Новый Массив);
	Определение.Вставить("ВозвращаемоеЗначение", Новый Структура);
	Определение.Вставить("Доступность", Новый Массив);
	Определение.ВозвращаемоеЗначение.Вставить("Типы", Новый Массив);
	Определение.Вставить("Пример", Новый Массив);
	Определение.Вставить("ЕстьЗначения", Ложь);
	Возврат Определение;
КонецФункции

Функция ЭтоКлючевоеСлово(ОбластьПоиска, Ключевое)
	Возврат СтрНайти(ОбластьПоиска, Ключевое) > 0;
КонецФункции

Функция ЭтоСледующаяРубрика(Узел)
	
	Если Узел = Неопределено Тогда
		Возврат Истина;
	КонецЕсли;
	
	Результат = Ложь;
	
	Если Не ТипЗнч(Узел) = Тип("ТекстDOM") Тогда
		Результат = (Узел.ИмяУзла = "div" Или Узел.ИмяУзла = "p") И Узел.ИмяКласса = "V8SH_rubric";
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Функция ЭтоСледующаяГлава(Узел)
	
	Если Узел = Неопределено Тогда
		Возврат Истина;
	КонецЕсли;
	
	Результат = Ложь;
	
	Если Не ТипЗнч(Узел) = Тип("ТекстDOM") Тогда
		Результат = (Узел.ИмяУзла = "div" Или Узел.ИмяУзла = "p") И ЭтоГлава(Узел);
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Функция ЭтоГлава(Узел)
	Попытка
		Возврат Узел.ИмяКласса = "V8SH_chapter";	
	Исключение
		Возврат Ложь;
	КонецПопытки;
КонецФункции

Функция ЗначениеИзУзла(Следующий)
	
	Если Следующий.ИмяУзла = "#text" Тогда
		Значение = Следующий.ТекстовоеСодержимое;
	ИначеЕсли ТипЗнч(Следующий) = Тип("ЭлементЯкорьHTML") Тогда
		Значение = СтрШаблон("<a href=""%1"">%2</a>", Следующий.Гиперссылка, Следующий.ТекстовоеСодержимое);
	Иначе
		Значение = innerHTML(Следующий);
	КонецЕсли;
	
	Возврат Значение;
	
КонецФункции

Функция innerHTML(ЭлементHTML)
	ЗаписьDOM = Новый ЗаписьDOM;
	ЗаписьHTML = Новый ЗаписьHTML;
	ЗаписьHTML.УстановитьСтроку();
	Для Каждого Стр Из ЭлементHTML.ДочерниеУзлы Цикл
		Если Стр.ИмяУзла = "#text" Тогда
			Продолжить;
		ИначеЕсли Стр.ИмяУзла = "a" Тогда
			Продолжить;
		КонецЕсли;
		Попытка
			ЗаписьDOM.Записать(Стр, ЗаписьHTML);
		Исключение
			ОбщийМодуль.СообщитьПользователю(Стр.ТекстовоеСодержимое);
		КонецПопытки;
	КонецЦикла;
	Возврат ЗаписьHTML.Закрыть();
КонецФункции

Функция ЭтоТегЗаголовка(ЭлементDOM)
	Попытка
		Возврат ЭлементDOM.ИмяКласса = "V8SH_heading";
	Исключение
		Возврат Ложь;
	КонецПопытки;
КонецФункции

Функция ЭтоТегЗаголовкаСтраницы(ЭлементDOM)
	Попытка
		Возврат ЭлементDOM.ИмяКласса = "V8SH_pagetitle";
	Исключение
		Возврат Ложь;
	КонецПопытки;
КонецФункции

Функция ПрочитатьИдентификаторыЭлементаИзСтроки(Знач ТекстовоеЗначение)
	
	Пара = Новый Структура("Лево, Право", "", "");	
	
	Массив = СтрРазделить(ТекстовоеЗначение, "(");
	Пара.Лево = СокрЛП(Массив[0]);
	Если Массив.Количество() > 1 Тогда
		Пара.Право = ЧистыйИдентификатор(Массив[1]);
	КонецЕсли;
	
	Возврат Пара;
	
КонецФункции

Функция ЧистыйИдентификатор(Знач Значение)
	Значение = СокрЛП(Значение);
	Возврат СтрЗаменить(Значение, ")", "");
КонецФункции

#КонецОбласти

#КонецОбласти

#Область Инициализация

Кавычка = """";

#Область КлючевыеСлова

// Для русского языка
Ключевое_ВариантСинтаксиса = "Вариант синтаксиса:";
Ключевое_Синтаксис = "Синтаксис:";
Ключевое_Параметры = "Параметры:";
Ключевое_ОписаниеВарианта = "Описание варианта метода:";
Ключевое_Описание = "Описание:";
Ключевое_ВозвращаемоеЗначение = "Возвращаемое значение:";
Ключевое_Тип = "Тип:";
Ключевое_Доступность = "Доступность:";
Ключевое_Пример = "Пример:";
// Для английского зяыка
КлючевоеА_ВариантСинтаксиса = "Syntax variant:";
КлючевоеА_Синтаксис = "Syntax:";
КлючевоеА_Параметры = "Parameters:";
КлючевоеА_ОписаниеВарианта = "Description of method variant:";
КлючевоеА_Описание = "Description:";
КлючевоеА_ВозвращаемоеЗначение = "Returned value:";
КлючевоеА_Тип = "Type:";
КлючевоеА_Доступность = "Availability:";
КлючевоеА_Пример = "Example:";

#КонецОбласти

#КонецОбласти
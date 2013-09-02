/*
Copyright (c) 2008 De Pannekoek en De Kale B.V.,  www.dpdk.nl

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 */
 
package nl.dpdk.utils {

	/**
	 * Library class for some convenient date methods.
	 * @author Rolf Vreijdenberger
	 */
	public class DateUtils 
	{
		/**
		 * converts a timestamp in the ISO format yyyy-mm-dd hh:mm:ss to a date object.
		 * Mostly used to get a date from a database delivered timestamp in string format.
		 * @param timeStamp a string in the ISO format yyyy-mm-dd hh:mm:ss.
		 * @return a date object
		 */
		public static function timeStampToDate(timeStamp : String) : Date
		{
			
			var year : int = getYearFromTimeStamp(timeStamp);
			var month : int = getMonthFromTimeStamp(timeStamp) - 1;
			var day : int = getDayFromTimeStamp(timeStamp);
			var hour : int = getHourFromTimeStamp(timeStamp);
			var minute : int = getMinutesFromTimeStamp(timeStamp);
			var second : int = getSecondsFromTimeStamp(timeStamp);
			
			
			return new Date(year, month, day, hour, minute, second);
		}

		
		/**
		 * formats a date to a timestamp in the ISO format yyyy-mm-dd hh:mm:ss.
		 * can be meaningful when sending a date object to the backend which stores it in a timestamp field.
		 * @param date A date object
		 * @return a timestamp string in the format yyyy-mm-dd hh:mm:ss
		 */
		public static function dateToTimeStamp(date : Date) : String
		{
			var timeStamp : String;
			var year : String = prefixWithZeroWhenUnderTen(date.getFullYear());
			var month : String = prefixWithZeroWhenUnderTen(date.getMonth() + 1);
			var day : String = prefixWithZeroWhenUnderTen(date.getDate());
			var hour : String = prefixWithZeroWhenUnderTen(date.getHours());
			var minutes : String = prefixWithZeroWhenUnderTen(date.getMinutes());
			var seconds : String = prefixWithZeroWhenUnderTen(date.getSeconds());
			timeStamp = year + '-' + month + '-' + day + ' ' + hour + ':' + minutes + ':' + seconds;
			return timeStamp;
		}

		
		public static function prefixWithZeroWhenUnderTen(toPrefix : int) : String
		{
			var output : String;
			if(toPrefix >= 10 || toPrefix < 0) return String(toPrefix);
			output = '0' + String(toPrefix);
			return output;
		}
		
		

		/**
		 * gets the ISO formatted time part of a date object (hh:mm:ss)
		 * @param date Date
		 * @return ISO formatted time part
		 */
		public static function getTime(date : Date) : String
		{
			var output : String;
			var hour : String = prefixWithZeroWhenUnderTen(date.getHours());
			var minutes : String = prefixWithZeroWhenUnderTen(date.getMinutes());
			var seconds : String = prefixWithZeroWhenUnderTen(date.getSeconds());
			output = hour + ':' + minutes + ':' + seconds;
			return output;
		}
		
		/**
		 * gets the ISO formatted date part of a date object (yyyy-mm-dd).
		 * @param date Date
		 * @return ISO formatted date part
		 */
		public static function getDate(date : Date) : String
		{
			var output : String;
			var year : String = prefixWithZeroWhenUnderTen(date.getFullYear());
			var month : String = prefixWithZeroWhenUnderTen(date.getMonth() + 1);
			var day : String = prefixWithZeroWhenUnderTen(date.getDate());
			output = year + '-' + month + '-' + day;
			return output;
		}

		
		private static function getSecondsFromTimeStamp(timeStamp : String) : int
		{
			return parseInt(timeStamp.substr(17, 2));
		}

		
		private static function getMinutesFromTimeStamp(timeStamp : String) : int
		{
			return parseInt(timeStamp.substr(14, 2));
		}

		
		private static function getHourFromTimeStamp(timeStamp : String) : int
		{
			return parseInt(timeStamp.substr(11, 2));
		}

		
		private static function getDayFromTimeStamp(timeStamp : String) : int
		{
			return parseInt(timeStamp.substr(8, 2));
		}

		
		private static function getMonthFromTimeStamp(timeStamp : String) : int
		{
			return parseInt(timeStamp.substr(5, 2));
		}

		
		private static function getYearFromTimeStamp(timeStamp : String) : int
		{
			return parseInt(timeStamp.substr(0, 4));
		}

		
		public static function toString() : String
		{
			return "DateUtils";	
		}
	}
}

using System;

namespace CostManagement.Helpers
{
    public static class DateHelper
    {
        public static DateTime GetDate()
        {
            TimeZoneInfo setTimeZoneInfo;
            DateTime currentDateTime;
            //Set the time zone information to Central Standard Time México
            setTimeZoneInfo = TimeZoneInfo.FindSystemTimeZoneById("Central Standard Time (Mexico)");
            //Get date and time in Central Standard Time México
            currentDateTime = TimeZoneInfo.ConvertTime(DateTime.Now, setTimeZoneInfo);
            return currentDateTime;
        }

        public static int GetDayOfMonth()
        {
            return GetDate().Day;
        }

        public static int LastDayOfMonth()
        {
            var currentDate = GetDate();
            return DateTime.DaysInMonth(currentDate.Year, currentDate.Month);
        }

    }
}

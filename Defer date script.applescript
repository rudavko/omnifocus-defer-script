tell application "OmniFocus"
	
	set deferTime to value of setting id "DefaultStartTime" of default document
	
	set splitDeferTime to my splitText(deferTime as string, ":")
	
	set deferTimeHours to first item of splitDeferTime
	
	set deferTimeMinutes to second item of splitDeferTime
	
	set deferTimeSeconds to third item of splitDeferTime
	
	tell content of first document window of front document
		
		set selectedTasks to selected trees
		
		repeat with taskNum from 1 to count of selectedTasks
			
			set theTask to value of item taskNum of selectedTasks
			
			(*
			
			set simple defer date
			
			*)
			
			set nextDeferDate to current date
			
			if defer date of theTask is missing value then
				
				(*
				
				defer date is empty (either new task or defer date was removed manually)
				
				*)
				
				set nextDeferDate's hours to deferTimeHours
				
				set nextDeferDate's minutes to deferTimeMinutes
				
				set nextDeferDate's seconds to deferTimeSeconds
				
			else
				
				(*
				
				defer date is set (keep time, reschedule date only)
				
				*)
				
				set deferDate to defer date of theTask
				
				set nextDeferDate's hours to deferDate's hours
				
				set nextDeferDate's minutes to deferDate's minutes
				
				set nextDeferDate's seconds to deferDate's seconds
				
			end if
			
			if nextDeferDate � (current date) then
				
				set nextDeferDate to nextDeferDate + (1 * days)
				
			end if
			
			if (defer date of theTask is missing value or defer date of theTask � (current date)) and repetition rule of theTask is missing value then
				
				set defer date of theTask to nextDeferDate
				
			end if
			
			(*
			
			set defer date according to schedule (interval)
			
			*)
			
			set repRule to repetition rule of theTask
			
			if repRule is not missing value then
				
				set repMethod to repetition method of repRule as string
				
				set _frequency to recurrence of repRule
				
				set _repetition to repetition method of repRule
				
				if repMethod is equal to "fixed repetition" then
					
					--- condititon: "Repeat From This Item's: Completion"
					
					set nextDeferDate to next defer date of theTask
					
				else if repMethod is equal to "start after completion" then
					
					--- condition: "Repeat From This Item's: Assigned Dates"
					
					set repetition rule of theTask to {repetition method:fixed repetition, recurrence:_frequency}
					
					set nextDeferDate to next defer date of theTask
					
					set repetition rule of theTask to {repetition method:_repetition, recurrence:_frequency}
					
				else if repMethod is equal to "due after completion" then
					
					--- condition: "Schedule the Next: Due Date"
					
					---                (just created task with no due date or defer date)
					
					set repetition rule of theTask to {repetition method:start after completion, recurrence:_frequency}
					
				end if
				
				set defer date of theTask to nextDeferDate
				
			end if
			
		end repeat
		
	end tell
	
end tell

on splitText(theText, theDelimiter)
	
	set AppleScript's text item delimiters to theDelimiter
	
	set theTextItems to every text item of theText
	
	set AppleScript's text item delimiters to ""
	
	return theTextItems
	
end splitText

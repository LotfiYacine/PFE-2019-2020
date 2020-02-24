package fr.unice.i3s.uca4svr.toucan_vr.tracking.writers;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/**
 * Writes when user stop invisibleWall execution log into a specific logger (leading to a specific csv file).
 *
 */
public class InterruptedVirtualWallLogWriter extends LogWriter {

    // Each logger must have a different ID,
    // so that creating a new logger won't override the previous one
    private static int loggerNextID = 0;

    public InterruptedVirtualWallLogWriter(String logFilePrefix) {
        super(logFilePrefix, "fr.unice.i3s.uca4svr.tracking.writers.InterruptedVirtualWallLogWriter"
                + loggerNextID++);
    }

    /**
     * Builds the name of the logfile by appending the date to the logFilePrefix
     *
     * @param logFilePrefix the prefix for the log file
     * @return the name of the log file
     */
    @Override
    protected String createLogFileName(String logFilePrefix) {
        DateFormat dateFormat = new SimpleDateFormat("yyyy_MM_dd_HH_mm_ss", Locale.US);
        Date date = new Date();
        return String.format("%s_InterruptedVirtualWall_%s.csv", logFilePrefix, dateFormat.format(date));
    }

}

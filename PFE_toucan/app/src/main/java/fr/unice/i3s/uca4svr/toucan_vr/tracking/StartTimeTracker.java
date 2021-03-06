package fr.unice.i3s.uca4svr.toucan_vr.tracking;

import android.os.Environment;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import ch.qos.logback.classic.LoggerContext;
import ch.qos.logback.classic.encoder.PatternLayoutEncoder;
import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.core.FileAppender;

public class StartTimeTracker {
    // Each logger must have a different ID,
    // so that creating a new logger won't override the previous one
    private static int loggerNextID = 0;

    private final Logger logger;

    /**
     * Initialize a {@link StartTimeTracker}, that will record the start tap
     * during video to a file name logFilePrefix_s_StartTime__date.csv.
     *
     * @param logFilePrefix The prefix for the log file name
     */
    public StartTimeTracker(String logFilePrefix) {
        String logFilePath = Environment.getExternalStoragePublicDirectory("toucan/logs/")
                + File.separator
                + createLogFileName(logFilePrefix);

        // Initialize and configure a new logger in logback
        LoggerContext lc = (LoggerContext) LoggerFactory.getILoggerFactory();
        PatternLayoutEncoder encoder1 = new PatternLayoutEncoder();
        encoder1.setContext(lc);
        encoder1.setPattern("%msg%n");
        encoder1.start();

        FileAppender<ILoggingEvent> fileAppender = new FileAppender<>();
        fileAppender.setContext(lc);
        fileAppender.setFile(logFilePath);
        fileAppender.setEncoder(encoder1);
        fileAppender.start();

        // getting the instanceof the logger
        logger = LoggerFactory.getLogger("fr.unice.i3s.uca4svr.tracking.StartTimeTracker"
                + loggerNextID++);
        // I know the logger is from logback, this is the implementation i'm using below slf4j API.
        ((ch.qos.logback.classic.Logger) logger).addAppender(fileAppender);
    }

    /**
     * Builds the name of the logfile by appending the date to the logFilePrefix
     *
     * @param logFilePrefix the prefix for the log file
     * @return the name of the log file
     */
    private String createLogFileName(String logFilePrefix) {
        DateFormat dateFormat = new SimpleDateFormat("yyyy_MM_dd_HH_mm_ss", Locale.US);
        Date date = new Date();
        return String.format("%s_StartTime_%s.csv", logFilePrefix, dateFormat.format(date));
    }

    public void track(String time,long time2) {
        String string = String.format(Locale.ENGLISH, "%s,%d",
                time,time2);
        logger.error(string);
    }
}

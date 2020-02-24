/*
 * Copyright 2017 Laboratoire I3S, CNRS, Université côte d'azur
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package fr.unice.i3s.uca4svr.toucan_vr.dynamicEditing.operations;

import com.google.android.exoplayer2.ExoPlayer;
import com.google.android.exoplayer2.util.Clock;
import com.google.android.exoplayer2.util.SystemClock;

import org.gearvrf.GVRContext;
import org.gearvrf.GVRSceneObject;
import org.gearvrf.GVRTransform;
import org.gearvrf.scene_objects.GVRVideoSceneObjectPlayer;

import java.util.Arrays;
import java.util.Locale;

import fr.unice.i3s.uca4svr.toucan_vr.dynamicEditing.DynamicEditingHolder;
import fr.unice.i3s.uca4svr.toucan_vr.tracking.DynamicOperationsTracker;
import fr.unice.i3s.uca4svr.toucan_vr.tracking.HeadMotionTracker;
import fr.unice.i3s.uca4svr.toucan_vr.tracking.HeadSpeedTracker;
import fr.unice.i3s.uca4svr.toucan_vr.tracking.TimeInsideVWTracker;
import fr.unice.i3s.uca4svr.toucan_vr.utils.Angles;
import fr.unice.i3s.uca4svr.toucan_vr.utils.RotationTool;

/**
 * InvisibleWall technique as described in further research documentation.
 * Implements the operation's data and behavior.
 *
 * @author Antoine Dezarnaud
 */

public class InvisibleWall extends DynamicOperation {

    //Degree snapchange
    private int roiDegrees;
    //Center of the wall
    private float centerOfWallAngle;
    //Number of degrees that the user is free to rotate on Y axis
    private int freedomYDegrees = 0;
    //Number of degrees that the uxser is free to rotate on X axis
    private int freedomXDegrees = 0;
    //Duration of this operation
    private int millisInvisibleWallDuration;

    private int[] foVTiles;

    private boolean roiDegreesFlag;
    private boolean foVTilesFlag;
    private boolean triggered;
    private boolean recenterView;
    private boolean userDeblockVirtuallWall;

    private float lastRotation;
    private int NOT_INITIALIZED = -1000;
    private float degreeYbeforeBlocking = NOT_INITIALIZED;

    private DynamicOperationsTracker tracker;
    private long realStartTime;
    // Changes for proper logging
    private final Clock clock;

    private long timeInsideVirtualWall;
    private long timeOutSideVirtualWall;

    private class MyRunnableLogging implements Runnable {

        private boolean doStop = false;
        private long curVideoTime;
        private float currentUserRotation;
        private boolean userLookingOutOfWallsLimits;

        public InvisibleWall invisibleWall;
        public GVRVideoSceneObjectPlayer<ExoPlayer> player;
        public GVRSceneObject videoHolder;
        public HeadMotionTracker headMotionTracker;
        public DynamicOperationsTracker tracker;
        TimeInsideVWTracker timeInsideVWTracker;

        public MyRunnableLogging(InvisibleWall invisibleWall, GVRVideoSceneObjectPlayer<ExoPlayer> player, GVRSceneObject videoHolder, HeadMotionTracker headMotionTracker, DynamicOperationsTracker tracker) {
            super();
            this.invisibleWall = invisibleWall;
            this.player = player;
            this.videoHolder = videoHolder;
            this.headMotionTracker = headMotionTracker;
            this.tracker = tracker;
            timeInsideVWTracker = new TimeInsideVWTracker(dynamicEditingHolder.logPrefix);
        }

        public synchronized void doStop() {
            this.doStop = true;
        }

        private synchronized boolean keepRunning() {
            return this.doStop == false;
        }

        private void do_logging() {
            userLookingOutOfWallsLimits = invisibleWall.checkUserHeadRotation(videoHolder);
            curVideoTime = player.getPlayer().getCurrentPosition();
            currentUserRotation = Angles.getCurrentYAngle(videoHolder.getGVRContext());
            headMotionTracker.track(curVideoTime, videoHolder, dynamicEditingHolder);
            invisibleWall.logIn_inWall(tracker, curVideoTime, currentUserRotation, userLookingOutOfWallsLimits);
            timeInsideVWTracker.track(clock.elapsedRealtime(), timeInsideVirtualWall, curVideoTime, userLookingOutOfWallsLimits, timeOutSideVirtualWall);
        }

        @Override
        public void run() {
            while (keepRunning()) {
                do_logging();
                try {
                    Thread.sleep(100L);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }
    }
    /// End changes for proper logging

    public InvisibleWall(DynamicEditingHolder dynamicEditingHolder) {
        super(dynamicEditingHolder);
        this.roiDegreesFlag = this.foVTilesFlag = false;
        this.clock = new SystemClock();
        userDeblockVirtuallWall = false;
    }

    public void setRoiDegrees(int roiDegrees) {
        this.roiDegrees = roiDegrees;
        this.roiDegreesFlag = true;
    }

    public void setFoVTiles(int[] foVTiles) {
        this.foVTiles = foVTiles;
        this.foVTilesFlag = true;
    }

    @Override
    public boolean isWellDefined() {
        return super.isWellDefined() && this.roiDegreesFlag && this.foVTilesFlag;
    }

    /**
     * This method check and track user's head motions in order to know if the user gaze outside the walls.
     *
     * @param videoHolder
     */
    private boolean checkUserHeadRotation(GVRSceneObject videoHolder) {

        boolean userGazeOutOfWalls = false;

        //check Y rotation
        float currentYangle = Angles.getCurrentYAngle(videoHolder.getGVRContext());
        boolean userGazeInAngleY = Angles.isAngleInAngleField(currentYangle, centerOfWallAngle, freedomYDegrees);

        userGazeOutOfWalls = !userGazeInAngleY;

        // update last limit angle
        if ((userGazeOutOfWalls && degreeYbeforeBlocking == NOT_INITIALIZED) || //first time out of the walls
                (!userGazeOutOfWalls && degreeYbeforeBlocking != NOT_INITIALIZED)) { //first time between the walls

            if (Angles.isMoreToTheRight(centerOfWallAngle, currentYangle)) {
                degreeYbeforeBlocking = Angles.subtractDegrees(roiDegrees, freedomYDegrees / 2);
            } else {
                degreeYbeforeBlocking = Angles.addDegrees(roiDegrees, freedomYDegrees / 2);
            }
        }

        return userGazeOutOfWalls;
    }

    @Override
    public void activate(GVRVideoSceneObjectPlayer<ExoPlayer> player, GVRSceneObject videoHolder, HeadMotionTracker headMotionTracker, DynamicOperationsTracker tracker) {
        this.tracker = tracker;
        if (!dynamicEditingHolder.tap && !dynamicEditingHolder.insistence) {
            virtualWall(player, videoHolder, headMotionTracker, tracker);
        } else {
            if (dynamicEditingHolder.tap) {
                tap(player, videoHolder, headMotionTracker, tracker);
            } else if (dynamicEditingHolder.insistence) {
                insistence(player, videoHolder, headMotionTracker, tracker);
            }
        }
    }

    private void virtualWall(GVRVideoSceneObjectPlayer<ExoPlayer> player, GVRSceneObject
            videoHolder, HeadMotionTracker headMotionTracker, DynamicOperationsTracker tracker) {
        //Initial snap change
        RotationTool.alignUserGazeTo(roiDegrees, videoHolder, dynamicEditingHolder);
        //the center of walls become the current user position
        centerOfWallAngle = Angles.getCurrentYAngle(videoHolder.getGVRContext());

        //apply rotation restrictions
        //while the operation duration is not finished, control user's gaze
        this.realStartTime = player.getPlayer().getCurrentPosition();
        long curVideoTime = realStartTime;
        boolean userLookingOutOfWallsLimits;
        float currentUserRotation;

        // Start loging thread not to impact wall smoothness
        MyRunnableLogging myRunnableLogging = new MyRunnableLogging(this, player, videoHolder, headMotionTracker, tracker);
        Thread thread = new Thread(myRunnableLogging, "MyLogging");
        thread.start();
        ///
        while (curVideoTime - realStartTime < millisInvisibleWallDuration && !userDeblockVirtuallWall) {
            userLookingOutOfWallsLimits = checkUserHeadRotation(videoHolder);
            currentUserRotation = Angles.getCurrentYAngle(videoHolder.getGVRContext());

            if (userLookingOutOfWallsLimits) {
                blockUserGaze(currentUserRotation, videoHolder);
            } else {
                deblockUserGaze(currentUserRotation, videoHolder);
            }
            curVideoTime = player.getPlayer().getCurrentPosition();
        }
        myRunnableLogging.doStop();
        dynamicEditingHolder.advance();
    }

    private void tap(GVRVideoSceneObjectPlayer<ExoPlayer> player, GVRSceneObject
            videoHolder, HeadMotionTracker headMotionTracker, DynamicOperationsTracker tracker) {
        timeInsideVirtualWall = 0;
        timeOutSideVirtualWall = 0;
        //Initial snap change
        RotationTool.alignUserGazeTo(roiDegrees, videoHolder, dynamicEditingHolder);
        //the center of walls become the current user position
        centerOfWallAngle = Angles.getCurrentYAngle(videoHolder.getGVRContext());

        //apply rotation restrictions
        //while the operation duration is not finished, control user's gaze
        this.realStartTime = player.getPlayer().getCurrentPosition();
        long curVideoTime = realStartTime;
        boolean userLookingOutOfWallsLimits;
        float currentUserRotation;

        // Start loging thread not to impact wall smoothness
        MyRunnableLogging myRunnableLogging = new MyRunnableLogging(this, player, videoHolder, headMotionTracker, tracker);
        Thread thread = new Thread(myRunnableLogging, "MyLogging");
        thread.start();
        ///
        while (curVideoTime - realStartTime < millisInvisibleWallDuration) {
            while (curVideoTime - realStartTime < millisInvisibleWallDuration && !userDeblockVirtuallWall) {
                userLookingOutOfWallsLimits = checkUserHeadRotation(videoHolder);
                currentUserRotation = Angles.getCurrentYAngle(videoHolder.getGVRContext());

                if (userLookingOutOfWallsLimits) {
                    blockUserGaze(currentUserRotation, videoHolder);
                } else {
                    deblockUserGaze(currentUserRotation, videoHolder);
                }
                curVideoTime = player.getPlayer().getCurrentPosition();
            }
            //bad quality
            dynamicEditingHolder.setFlagBreakVW(true);

            //4s out of virtual wall
            deblockVW(curVideoTime, player, videoHolder);

            resetTapWall(videoHolder);

            curVideoTime = player.getPlayer().getCurrentPosition();
        }
        myRunnableLogging.doStop();
        dynamicEditingHolder.advance();
        userDeblockVirtuallWall = true;
    }

    private void resetTapWall(GVRSceneObject videoHolder) {
        userDeblockVirtuallWall = false;
        timeOutSideVirtualWall = 0;
        degreeYbeforeBlocking = NOT_INITIALIZED;
        //Initial snap change
        RotationTool.alignUserGazeTo(roiDegrees, videoHolder, dynamicEditingHolder);
        //the center of walls become the current user position
        centerOfWallAngle = Angles.getCurrentYAngle(videoHolder.getGVRContext());
    }

    private void insistence(GVRVideoSceneObjectPlayer<ExoPlayer> player, GVRSceneObject
            videoHolder, HeadMotionTracker headMotionTracker, DynamicOperationsTracker tracker) {
        timeInsideVirtualWall = 0;
        timeOutSideVirtualWall = 0;
        //Initial snap change
        RotationTool.alignUserGazeTo(roiDegrees, videoHolder, dynamicEditingHolder);
        //the center of walls become the current user position
        centerOfWallAngle = Angles.getCurrentYAngle(videoHolder.getGVRContext());

        //apply rotation restrictions
        //while the operation duration is not finished, control user's gaze
        this.realStartTime = player.getPlayer().getCurrentPosition();
        long curVideoTime = realStartTime;
        boolean userLookingOutOfWallsLimits;
        float currentUserRotation;

        // Start loging thread not to impact wall smoothness
        MyRunnableLogging myRunnableLogging = new MyRunnableLogging(this, player, videoHolder, headMotionTracker, tracker);
        Thread thread = new Thread(myRunnableLogging, "MyLogging");
        thread.start();
        ///

        while (curVideoTime - realStartTime < millisInvisibleWallDuration) {
            long lastTimeInsideVirtualWall = 0;
            boolean insideVirtualWall = false;

            while (curVideoTime - realStartTime < millisInvisibleWallDuration && timeInsideVirtualWall <= 4000) {
                userLookingOutOfWallsLimits = checkUserHeadRotation(videoHolder);
                currentUserRotation = Angles.getCurrentYAngle(videoHolder.getGVRContext());

                if (userLookingOutOfWallsLimits) {
                    if (!insideVirtualWall) {
                        lastTimeInsideVirtualWall = player.getPlayer().getCurrentPosition();
                        insideVirtualWall = true;
                    } else {
                        timeInsideVirtualWall += timeInsideVirtualWall(lastTimeInsideVirtualWall, player.getPlayer().getCurrentPosition());
                        lastTimeInsideVirtualWall = player.getPlayer().getCurrentPosition();
                    }
                    blockUserGaze(currentUserRotation, videoHolder);
                } else {
                    if (insideVirtualWall) {
                        timeInsideVirtualWall += timeInsideVirtualWall(lastTimeInsideVirtualWall, player.getPlayer().getCurrentPosition());
                        insideVirtualWall = false;
                    }
                    deblockUserGaze(currentUserRotation, videoHolder);

                }
                curVideoTime = player.getPlayer().getCurrentPosition();

            }
            timeInsideVirtualWall = 0;
            //bad quality
            dynamicEditingHolder.setFlagBreakVW(true);

            //4s out of virtual wall
            deblockVW(curVideoTime, player, videoHolder);

            resetInsistenceWall(videoHolder);

            curVideoTime = player.getPlayer().getCurrentPosition();
        }
        myRunnableLogging.doStop();
        dynamicEditingHolder.advance();
    }

    private void resetInsistenceWall(GVRSceneObject videoHolder) {
        timeOutSideVirtualWall = 0;
        degreeYbeforeBlocking = NOT_INITIALIZED;
        //Initial snap change
        RotationTool.alignUserGazeTo(roiDegrees, videoHolder, dynamicEditingHolder);
        //the center of walls become the current user position
        centerOfWallAngle = Angles.getCurrentYAngle(videoHolder.getGVRContext());
    }

    private void deblockVW(long curVideoTime, GVRVideoSceneObjectPlayer<ExoPlayer> player, GVRSceneObject
            videoHolder) {
        long lastTimeInsideVirtualWall = 0;
        boolean insideVirtualWall = false;
        while (curVideoTime - realStartTime < millisInvisibleWallDuration && timeOutSideVirtualWall <= 4000) {
            if (!checkUserHeadRotation(videoHolder)) {
                if (!insideVirtualWall) {
                    lastTimeInsideVirtualWall = player.getPlayer().getCurrentPosition();
                    insideVirtualWall = true;
                } else {
                    timeOutSideVirtualWall += timeInsideVirtualWall(lastTimeInsideVirtualWall, player.getPlayer().getCurrentPosition());
                    lastTimeInsideVirtualWall = player.getPlayer().getCurrentPosition();
                }
            } else {
                if (insideVirtualWall) {
                    timeOutSideVirtualWall = 0;
                    insideVirtualWall = false;
                }
            }
            curVideoTime = player.getPlayer().getCurrentPosition();
        }
        //high quality
        dynamicEditingHolder.setFlagBreakVW(false);
    }

    private void deblockUserGaze(float currentUserRotation, GVRSceneObject videoHolder) {

        if (degreeYbeforeBlocking != NOT_INITIALIZED) {
            //RotationTool.alignUserGazeTo(degreeYbeforeBlocking,videoHolder,dynamicEditingHolder);
            float difference = currentUserRotation - (recenterView ? roiDegrees : degreeYbeforeBlocking);
            videoHolder.getTransform().setRotationByAxis(difference, 0, 1, 0);
            lastRotation = difference;

            // added by Lucile
            dynamicEditingHolder.lastRotation = lastRotation;

            degreeYbeforeBlocking = NOT_INITIALIZED;
        }
    }

    private void blockUserGaze(float currentUserRotation, GVRSceneObject videoHolder) {

        // calculating the rotation to apply to block the user's rotation on Y axis
        float difference = currentUserRotation - (recenterView ? roiDegrees : degreeYbeforeBlocking);
        videoHolder.getTransform().setRotationByAxis(difference, 0, 1, 0);
        lastRotation = difference;

        // added by Lucile
        dynamicEditingHolder.lastRotation = lastRotation;

    }

    @Override
    public void logIn(DynamicOperationsTracker tracker, long executionTime) {
        tracker.trackInvisibleWall(getMilliseconds(), executionTime, roiDegrees, triggered);
    }

    // added by Lucile
    private void logIn_inWall(DynamicOperationsTracker tracker, long curVideoTime,
                              float currentUserRotation, boolean userLookingOutOfWallsLimits) {

        float normalizedLastRotation = Angles.normalizeAngle(dynamicEditingHolder.lastRotation);
        float currentUserPosition_correctedwithSC = Angles.normalizeAngle(currentUserRotation - normalizedLastRotation);

        tracker.inWallLogWriter.writeLine(String.format(Locale.ENGLISH, "%1d,%2d,%3$.4f,%4$.4f,%5$.4f,%6$b",
                clock.elapsedRealtime(), curVideoTime,
                currentUserPosition_correctedwithSC, currentUserRotation, dynamicEditingHolder.lastRotation, userLookingOutOfWallsLimits));
    }

    @Override
    public int computeIdealTileIndex(int selectedIndex, int adaptationSetIndex,
                                     long nextChunkStartTimeUs) {
        int desiredIndex = Arrays.binarySearch(foVTiles, adaptationSetIndex) >= 0 ? 0 : 1;
        if (this.getMicroseconds() >= nextChunkStartTimeUs && desiredIndex == 1) {
            // The snap change involves the current chunk. Provide a smooth transition when the snap change
            // is forcing the quality to be low while the tile is still displayed to the user.
            return selectedIndex;
        } else {
            return desiredIndex;
        }
    }

    @Override
    public boolean hasToBeTriggeredInContext(GVRContext gvrContext) {
        //Always have to be triggered
        return true;
    }

    public int getSCroiDegrees() {
        return this.roiDegrees;
    }

    public int[] getSCfoVTiles() {
        return this.foVTiles;
    }

    public void setDuration(int millisDuration) {
        this.millisInvisibleWallDuration = millisDuration;
    }

    public void setFreeXDegrees(int freeXDegrees) {
        this.freedomXDegrees = freeXDegrees;
    }

    public void setFreeYDegrees(int freeYDegrees) {
        this.freedomYDegrees = freeYDegrees;
    }

    public void setRecenterView(boolean recenterView) {
        this.recenterView = recenterView;
    }


    @Override
    public void deactivate(GVRSceneObject
                                   videoHolder, GVRVideoSceneObjectPlayer<ExoPlayer> player) {
        if (!userDeblockVirtuallWall&& checkUserHeadRotation(videoHolder)) {
            userDeblockVirtuallWall = true;
            deblockUserGaze(Angles.getCurrentYAngle(videoHolder.getGVRContext()), videoHolder);
            this.tracker.InterruptedVirtualWallLogWriter(clock.elapsedRealtime(), getMilliseconds(), realStartTime, millisInvisibleWallDuration, realStartTime + millisInvisibleWallDuration, player.getPlayer().getCurrentPosition(), Angles.getCurrentYAngle(videoHolder.getGVRContext()));
        }
    }

    private long timeInsideVirtualWall(long previousTime, long currentTime) {
        return currentTime - previousTime;
    }

    private class MyRunnableSpeedTracking implements Runnable {

        private boolean doStop = false;
        public GVRSceneObject videoHolder;
        public DynamicOperationsTracker tracker;

        private float speed;
        private static final String LOGPREFIX = "Log";
        private HeadSpeedTracker headSpeedTracker;
        private GVRVideoSceneObjectPlayer<ExoPlayer> player;

        public MyRunnableSpeedTracking(GVRSceneObject videoHolder, GVRVideoSceneObjectPlayer<ExoPlayer> player) {
            super();
            this.videoHolder = videoHolder;
            this.player = player;
            this.headSpeedTracker = new HeadSpeedTracker(LOGPREFIX);
        }

        public synchronized void doStop() {
            this.doStop = true;
        }

        public synchronized float getSpeed() {
            return this.speed;
        }

        private synchronized boolean keepRunning() {
            return this.doStop == false;
        }

        private void speed(GVRSceneObject videoHolder) {
            float[] past_coordinates = new float[4]; // to store quaternions
            GVRTransform headTransform = videoHolder.getGVRContext().getMainScene().getMainCameraRig().getHeadTransform();

            past_coordinates[0] = headTransform.getRotationW();
            past_coordinates[1] = headTransform.getRotationX();
            past_coordinates[2] = headTransform.getRotationY();
            past_coordinates[3] = headTransform.getRotationZ();

            try {
                Thread.sleep(100);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

            float cur_headW = headTransform.getRotationW();
            float cur_headX = headTransform.getRotationX();
            float cur_headY = headTransform.getRotationY();
            float cur_headZ = headTransform.getRotationZ();

            float dW = (cur_headW - past_coordinates[0]) / (float) 100;
            float dX = (cur_headX - past_coordinates[1]) / (float) 100;
            float dY = (cur_headY - past_coordinates[2]) / (float) 100;
            float dZ = (cur_headZ - past_coordinates[3]) / (float) 100;

            this.speed = (float) Math.sqrt(dW * dW + dX * dX + dY * dY + dZ * dZ);
            headSpeedTracker.track(speed, player.getPlayer().getCurrentPosition());
        }

        @Override
        public void run() {
            while (keepRunning()) {
                speed(videoHolder);
            }
        }
    }
}

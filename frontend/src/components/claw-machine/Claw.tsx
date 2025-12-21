"use client";

import { motion } from "framer-motion";

interface ClawProps {
  x: number;
  y: number;
  isGrabbing: boolean;
  isAnimating: boolean;
  isIdle: boolean;
  showGrabEffect?: boolean; // 显示明显的合爪效果
}

export default function Claw({ x, y, isGrabbing, isAnimating, isIdle, showGrabEffect = false }: ClawProps) {
  // In idle mode, arms animate open/close to hint user to click
  // When grabbing, arms close fully with enhanced angle
  const getArmRotation = (baseAngle: number, isLeft: boolean) => {
    if (isGrabbing) {
      // 增强合爪角度，从35度增加到50度，更明显的闭合
      return isLeft ? 50 : -50;
    }
    if (isIdle && !isAnimating) {
      // Idle grab-release animation cycle
      return isLeft ? [8, 30, 8] : [-8, -30, -8];
    }
    return isLeft ? 10 : -10;
  };

  // 下部爪尖的额外闭合角度
  const getLowerArmRotation = (isLeft: boolean) => {
    if (isGrabbing) {
      // 增强爪尖闭合，更明显的抓取效果
      return isLeft ? -25 : 25;
    }
    if (isIdle && !isAnimating) {
      return isLeft ? [-3, -15, -3] : [3, 15, 3];
    }
    return 0;
  };

  return (
    <motion.div
      className="absolute z-20 pointer-events-none"
      animate={{ x, y }}
      transition={
        isAnimating
          ? { type: "spring", stiffness: 100, damping: 20 }
          : { type: "spring", stiffness: 300, damping: 30 }
      }
      style={{ left: "50%", top: 0, marginLeft: -24 }}
    >
      {/* Cable/rope */}
      <motion.div
        className="relative mx-auto"
        style={{ width: 3 }}
        animate={{ height: Math.max(16, y + 16) }}
      >
        {/* Main cable */}
        <div className="absolute inset-0 bg-gradient-to-b from-gray-600 via-gray-500 to-gray-400 rounded-full" />
        {/* Cable segments */}
        {Array.from({ length: Math.floor((y + 16) / 12) }).map((_, i) => (
          <div
            key={i}
            className="absolute left-0 right-0 h-0.5 bg-gray-700/30"
            style={{ top: i * 12 + 8 }}
          />
        ))}
      </motion.div>

      {/* Claw mechanism with idle swing */}
      <motion.div
        className="relative"
        animate={
          isIdle && !isAnimating
            ? { rotate: [-1.5, 1.5, -1.5], y: [0, 0.5, 0] }
            : { rotate: 0, y: 0 }
        }
        transition={
          isIdle && !isAnimating
            ? { duration: 2.5, repeat: Infinity, ease: "easeInOut" }
            : { duration: 0.2 }
        }
      >
        {/* Motor housing - compact */}
        <div className="relative mx-auto" style={{ width: 44 }}>
          {/* Top connector */}
          <div className="w-4 h-2 bg-gradient-to-b from-gray-500 to-gray-600 mx-auto rounded-sm" />

          {/* Main motor body */}
          <div className="relative">
            <div className="w-11 h-6 bg-gradient-to-b from-red-500 via-red-600 to-red-700 rounded-md mx-auto shadow-lg border border-red-800 flex items-center justify-center">
              {/* Control light */}
              <motion.div
                className="w-2 h-2 rounded-full bg-gradient-to-br from-yellow-300 to-yellow-500"
                animate={{ opacity: [0.6, 1, 0.6] }}
                transition={{ duration: 1, repeat: Infinity }}
                style={{ boxShadow: "0 0 6px rgba(251, 191, 36, 0.8)" }}
              />
            </div>
            {/* Bottom plate */}
            <div className="w-9 h-1.5 bg-gradient-to-b from-gray-500 to-gray-700 mx-auto rounded-b-sm" />
          </div>
        </div>

        {/* Claw arms container - compact */}
        <div className="flex justify-center -mt-0.5">
          {/* Left arm */}
          <motion.div
            className="origin-top"
            animate={{ rotate: getArmRotation(10, true) }}
            transition={
              isIdle && !isAnimating
                ? { duration: 1.2, repeat: Infinity, ease: "easeInOut" }
                : { type: "spring", stiffness: 200, damping: 15 }
            }
          >
            <div className="relative" style={{ width: 8 }}>
              {/* Upper arm segment */}
              <div className="w-2 h-6 bg-gradient-to-r from-gray-400 via-gray-300 to-gray-400 rounded-sm shadow-sm mx-auto border border-gray-500" />
              {/* Joint */}
              <div className="w-2.5 h-2.5 bg-gradient-to-b from-gray-400 to-gray-600 rounded-full mx-auto -mt-0.5 border border-gray-700" />
              {/* Lower arm with claw tip */}
              <motion.div
                className="origin-top -mt-0.5"
                animate={{ rotate: getLowerArmRotation(true) }}
                transition={
                  isIdle && !isAnimating
                    ? { duration: 1.2, repeat: Infinity, ease: "easeInOut" }
                    : { type: "spring", stiffness: 150, damping: 12 }
                }
              >
                <div className="w-1.5 h-5 bg-gradient-to-b from-gray-400 to-gray-500 rounded-b-lg mx-auto border border-gray-600" />
                {/* Claw tip */}
                <motion.div
                  className="w-2.5 h-3 bg-gradient-to-b from-orange-400 to-orange-600 rounded-b-full mx-auto -mt-0.5 shadow-sm border border-orange-700"
                  animate={isGrabbing ? { scale: [1, 1.1, 1] } : {}}
                  transition={{ duration: 0.3, repeat: isGrabbing ? Infinity : 0 }}
                />
              </motion.div>
            </div>
          </motion.div>

          {/* Center arm */}
          <motion.div
            animate={{ scaleY: isGrabbing ? 0.95 : isIdle && !isAnimating ? [1, 0.92, 1] : 1 }}
            transition={
              isIdle && !isAnimating
                ? { duration: 1.2, repeat: Infinity, ease: "easeInOut" }
                : { type: "spring", stiffness: 200, damping: 15 }
            }
            className="mx-0.5"
          >
            <div className="relative" style={{ width: 8 }}>
              <div className="w-2 h-7 bg-gradient-to-r from-gray-400 via-gray-300 to-gray-400 rounded-sm shadow-sm mx-auto border border-gray-500" />
              <div className="w-2.5 h-2.5 bg-gradient-to-b from-gray-400 to-gray-600 rounded-full mx-auto -mt-0.5 border border-gray-700" />
              <div className="w-1.5 h-6 bg-gradient-to-b from-gray-400 to-gray-500 rounded-b-lg mx-auto -mt-0.5 border border-gray-600" />
              <div className="w-2.5 h-3.5 bg-gradient-to-b from-orange-400 to-orange-600 rounded-b-full mx-auto -mt-0.5 shadow-sm border border-orange-700" />
            </div>
          </motion.div>

          {/* Right arm */}
          <motion.div
            className="origin-top"
            animate={{ rotate: getArmRotation(-10, false) }}
            transition={
              isIdle && !isAnimating
                ? { duration: 1.2, repeat: Infinity, ease: "easeInOut" }
                : { type: "spring", stiffness: 200, damping: 15 }
            }
          >
            <div className="relative" style={{ width: 8 }}>
              <div className="w-2 h-6 bg-gradient-to-r from-gray-400 via-gray-300 to-gray-400 rounded-sm shadow-sm mx-auto border border-gray-500" />
              <div className="w-2.5 h-2.5 bg-gradient-to-b from-gray-400 to-gray-600 rounded-full mx-auto -mt-0.5 border border-gray-700" />
              <motion.div
                className="origin-top -mt-0.5"
                animate={{ rotate: getLowerArmRotation(false) }}
                transition={
                  isIdle && !isAnimating
                    ? { duration: 1.2, repeat: Infinity, ease: "easeInOut" }
                    : { type: "spring", stiffness: 150, damping: 12 }
                }
              >
                <div className="w-1.5 h-5 bg-gradient-to-b from-gray-400 to-gray-500 rounded-b-lg mx-auto border border-gray-600" />
                <motion.div
                  className="w-2.5 h-3 bg-gradient-to-b from-orange-400 to-orange-600 rounded-b-full mx-auto -mt-0.5 shadow-sm border border-orange-700"
                  animate={isGrabbing ? { scale: [1, 1.1, 1] } : {}}
                  transition={{ duration: 0.3, repeat: isGrabbing ? Infinity : 0 }}
                />
              </motion.div>
            </div>
          </motion.div>
        </div>
      </motion.div>

      {/* Grab glow effect - enhanced */}
      {isGrabbing && (
        <>
          {/* 主发光效果 */}
          <motion.div
            className="absolute -bottom-2 left-1/2 transform -translate-x-1/2"
            initial={{ scale: 0, opacity: 0.8 }}
            animate={{ scale: [1, 1.5, 1], opacity: [0.8, 0.3, 0.8] }}
            transition={{ duration: 0.4, repeat: Infinity }}
          >
            <div className="w-10 h-10 bg-yellow-400 rounded-full blur-md" />
          </motion.div>
          {/* 额外的能量环效果 */}
          <motion.div
            className="absolute -bottom-3 left-1/2 transform -translate-x-1/2"
            initial={{ scale: 0.5, opacity: 0 }}
            animate={{ scale: [0.5, 2, 0.5], opacity: [0, 0.6, 0] }}
            transition={{ duration: 0.6, repeat: Infinity }}
          >
            <div className="w-12 h-12 border-2 border-yellow-300 rounded-full" />
          </motion.div>
          {/* 合爪提示文字 */}
          {showGrabEffect && (
            <motion.div
              className="absolute -bottom-8 left-1/2 transform -translate-x-1/2 whitespace-nowrap"
              initial={{ opacity: 0, y: 5 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.2 }}
            >
              <span className="text-yellow-300 text-xs font-bold drop-shadow-lg">GRABBING!</span>
            </motion.div>
          )}
        </>
      )}
    </motion.div>
  );
}

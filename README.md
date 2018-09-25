
# react-native-rtsp-library

## Getting started

`$ npm install react-native-rtsp-library --save`

### Mostly automatic installation

`$ react-native link react-native-rtsp-library`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-rtsp-library` and add `RNRtspLibrary.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNRtspLibrary.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.hanif.reactnativertsp.RNRtspLibraryPackage;` to the imports at the top of the file
  - Add `new RNRtspLibraryPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-rtsp-library'
  	project(':react-native-rtsp-library').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-rtsp-library/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-rtsp-library')
  	```


## Usage
```javascript
import RNRtspLibrary from 'react-native-rtsp-library';

// TODO: What to do with the module?
RNRtspLibrary;
```
  
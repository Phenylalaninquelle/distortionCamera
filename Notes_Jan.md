# Distortion Camera

### Überlegungen/Todos

- Klasse DistortionCamera
	- Zwei Methoden: GenerateRay und GenerateRayDifferential
	- Wo in der Klassenhierarchie?
	- Welche(s) Verzeichnungsmodell(e) implementiert man?
- Factory-Funktion für DistortionCamera `CreateDistortionCamera`
- Erweitern der API
	- Scene File Syntax -> welche Argumente braucht man?
		- Parameter für das Verzeichnungsmodell (Lesen wir **Ver**zeichnungsparameter oder **Ent**zeichnungsparameter ein?
		- evtl. Angabe, welches Verzeichnungsmodell überhaupt genutzt wird, dann müssen die Parameter entsprechend anders interpretiert werden
		- Alles was die PerspectiveCamera auch hat??
	- in `api.cpp` muss die `MakeCamera()` Funktion erweitert werden
- Linsendaten-Files von LensFun einlesen können? Hängt wahrscheinlich davon ab, wie aufwendig das parsen von XML-Dateien ist ohne da große neue Abhängigkeiten reinzukriegen.
	
### Unklarheiten

- Reicht so eine gemessene Verzeichnung überhaupt aus, um Strahlen zu erzeugen? Oder brauch man quasi eine perspektivische Abbildung, wo dann im Bild die Verzerrung nachher aufgeprägt wird? Oder ist das alles schon in der gemessenen Verzeichnung drin??
	
### Modelle

Aus dem Tang-Paper:
 - **Radial model**: $r_2 = r_1 \cdot (k_0 + k_1 \cdot r_1 + k_2 \cdot r_1^2 + ...) = r_1 \cdot \sum_{i = 0}^{n}k_i \cdot r_1^i$
 - **Polynomial Model**: Polynome in $x_1$ und $y_1$. Bildungsvorschrift ist ein bisschen nebulös.

[LensFun](http://lensfun.sourceforge.net/manual/v0.3.2/group__Lens.html#gaa505e04666a189274ba66316697e308e) Datenbank benutzt Abarten vom Radial Model:
 - **Poly3:** $ r_d = r_u \cdot (1 - k_1 + k_2 r_u^2) $
 - **Poly5:** $ r_d = r_u \cdot (1 + k_1 r_u^2 + k_2 r_u^4) $
 - **PTLens:** $ r_d \cdot (a r_u^3 + b r_u^2 + c r_u + 1 - a - b - c) $
Wenn man daraus Daten nutzen will, muss man das radial model implementieren.

### Argumente für das Kamera-Objekt
Bisher haben die Kameras diese Parameter:

- Alle:
	- `shutteropen`
	- `shutterclose`
	- (die machen auch Sinn für unsere Kamera)
- Perspective, Orthographic und Environment:
	- `frameaspectratio` -> kommt automatisch aus Auflösung des Films, könnte man also erstmal weglassen
	- `screenwindow` (versteh ich nicht, was das tut)
- Perspective und Orthographic (für depth of field)
	- `lensradius`
	- `focaldistance`
	- (brauchen wir das auch? Oder ist das durch das Verzeichnungsmodell schon eingefangen? Ich schätze, wir brauchen das)
- Perspective:
	- `fov`
	- (brauchen wir, vermute ich)
	
```c++
/* Mögliche Argumente */
string distortion_model // sowas wie "radial", "polynomial"...
float model_coeffs // array mit koeffizienten für das entsprechende Modell
// alle, die die perspective auch hat:
float shutteropen;
float shutterclose;
float frameaspectratio;
float screenwindow;
float lensradius;
float focaldistance;
float fov;
float halffov;

```
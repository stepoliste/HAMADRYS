# Hamadrys: Breathing Trees of the City

**Hamadrys** is an interactive audiovisual installation that transforms real-time air quality data into breathing tree forms and generative soundscapes. This repository contains the working prototype.

## Getting Started

The patch is **ready to use**. Follow these steps:

1. Clone or download the repository to your computer.
2. Ensure the following files are in the **same folder**:
   - `hamadrys.toe` (TouchDesigner file)
   - `tree.obj` (3D tree model)
3. Open the software:
   - Open `hamadrys.scd` in SuperCollider.
   - Open `hamadrys.toe` in TouchDesigner.
4. Fix the sample path in SuperCollider:
   - Locate `cpac.wav` inside `hamadrys.scd`.
   - Update the path to match your local location of the sample.
5. Fix the tree path in Touchdesigner:
   - Locate `treelungs.obj`.
   - Update the path to match your local location of the object.
6. Run the patch:
   - Start the SuperCollider code.
   - Launch TouchDesigner.
   - Audio and visuals will respond in real-time via OSC.

## Requirements

- TouchDesigner (for visuals and L-system trees)
- SuperCollider (for sound synthesis)
- Python (for OSC communication and optional API integration)
- Optional: OpenAI API key for generative text messages

## Notes

- The prototype currently uses air quality data from the **Regione Lombardia API** (Milan) but can be adapted to other APIs.
- Only `hamadrys.toe` and `tree.obj` must be in the same folder. The SuperCollider sample path is the only manual adjustment required.

## Credits

- **Riccardo Corà** 
- **Riccardo Moschen** 
- **Stefano Polimeno**  

## Links

- Demo video: [[https://youtube.com/yourvideo](https://youtube.com/yourvideo](https://youtu.be/zJB9eDWm9mI))  
- Presentation slides: [https://linktopresentation.com](https://linktopresentation.com)

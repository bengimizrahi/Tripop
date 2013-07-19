version8/README.txt 'deki algoritmai uyguladik ama sadece bir eksik var:

Bizim prevPosition, prev Rotation icin gecerli. Biz ise hep current rotation value kullandigimiz icin, hep dd = dt*velocity kaliyor, hic degismiyor.

* Eski rotation value uzerinden prevPosition islemleri yapmalisin.


class Ball:
    def position():
        pass
    
    def positionOnLayer(layer):
        rotation = layer.rotation
        angle rotation
        return pos(angle, pos)

    def prevPositionOnLayer(layer):
        prevRotation = layer.prevRotation
        angle = prevRotation
        return pos(angle, prevPos)

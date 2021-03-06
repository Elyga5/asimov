#!/bin/bash
trap "exit 1" SIGTERM

if [ -z $1 ];then
  echo "Usage: $0 filename printer"
  exit 1
fi

filename=~/stl/$(basename $1)
host=pulsar.unizar.es
printer=$2
remotehost=p_$printer@$host
# Script para lanzar sliceado en remoto
unlink $HOME/.skeinforge
ln -s /home/asimov/impresoras/$printer/dot-skeinforge ${HOME}/.skeinforge
python /home/asimov/software/Printrun/skeinforge/skeinforge_application/skeinforge.py
#echo "Borrando .skeinforge remoto"
#ssh $remotehost 'rm -rf .skeinforge'
echo "Copiando .skeinforge"
rsync -azPL ~/.skeinforge ${remotehost}:
#scp -r ~/.skeinforge/ $remotehost:

# Copio el .stl al home de pulsar del usuario corresponiente
echo "Copiando fichero stl"
scp "$1" $remotehost:stl/

ssh $remotehost "python /opt/skeinforge/skeinforge_application/skeinforge_utilities/skeinforge_craft.py stl/$(basename $filename)" | strings

echo "Copiando fichero de $remotehost a localhost"
scp $remotehost:stl/$(basename "${filename%.*}_export.gcode") $(basename "${filename%.*}_$printer.gcode")
echo "Copiando fichero de localhost a octoprint@${printer}"
echo "scp $(basename \"${filename%.*}_$printer.gcode\") octoprint@${printer}:/home/octoprint/.octoprint/uploads/"
scp $(basename "${filename%.*}_$printer.gcode") octoprint@${printer}:/home/octoprint/.octoprint/uploads/

echo "Copiado fichero a octoprint@${printer}"

#scp $remotehost:stl/$(basename "${filename%.*}_export.gcode") ${printer}@${printer}:gcode/$(basename "${filename%.*}_$printer.gcode")

